-- Parse sam file
-- Attach row_id
-- Extract cigar string into list of length+operation pairs
CREATE TABLE IF NOT EXISTS sam AS 
SELECT
    row_number() OVER () as row_id,
    *,
    regexp_extract_all(cigar, '(\d+)([MIDNSHP=X])') AS cigar_parts,
FROM read_csv('test.sam',
    delim="\t",
    comment='@',
    names = [
        qname,
        flag,
        rname,
        pos,
        mapq,
        cigar,
        rnext,
        pnext,
        tlen,
        seq,
        qual 
    ]
);
-- Get lengths that consume reference, then unnest
-- Attach subscript for multi cigar operation entries
EXPLAIN ANALYZE WITH sam_refconsuminglens AS (
    SELECT
        row_id,
        qname,
        pos,
        cigar,
        UNNEST(
            list_transform(
                cigar_parts,
                x ->  CASE WHEN x[-1] IN ('M', 'D', 'N', '=', 'X') THEN x[:-2]::INTEGER ELSE NULL END
                )::INTEGER[]
            ) AS lens, generate_subscripts(cigar_parts,1) AS index
    FROM sam
),
-- Perform cumulative sum of ref-consuming lengths
sam_cumsum AS (
    SELECT
        row_id
        qname,
        pos,
        cigar,
        lens,
        sum(lens) OVER (PARTITION BY row_id ORDER BY index)::INT AS cum_sum
    FROM sam_refconsuminglens
    ORDER BY row_id
)
-- Calculate coverage by counting ref-consuming positions
SELECT ref_pos, count(ref_pos) AS count
FROM sam_cumsum, UNNEST(generate_series(pos+cum_sum-lens,pos+cum_sum-1)) AS t(ref_pos)
GROUP BY ref_pos
ORDER BY ref_pos




