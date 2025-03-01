-- Parse sam file
CREATE TABLE IF NOT EXISTS sam AS 
SELECT *
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


WITH cigar_strings AS (
    SELECT 
        row_number() OVER () AS row_id,
        cigar
    FROM
        unnest(['8M2I4M1D3M', '3M1I2M', '5M2D3M']) AS t(cigar)
),
parsed_operations AS (
    SELECT
        row_id,
        cigar,
        unnest(regexp_extract_all(cigar, '(\d+)([MIDNSHP=X])')) AS parts,
    FROM cigar_strings
),
operations AS (
    SELECT 
        cigar,
        row_number() OVER (PARTITION BY cigar ORDER BY row_id) AS op_id,
        parts[1]::INT AS len,
        parts[2] AS operation
    FROM parsed_operations
),
cumulative_positions AS (
    SELECT
        cigar,
        op_id,
        operation,
        len,
        sum(CASE WHEN operation IN ('M', 'D', 'N', '=', 'X') THEN len ELSE 0 END) 
            OVER (PARTITION BY cigar ORDER BY op_id)::INT AS cum_pos
    FROM operations
),
reference_ranges AS (
    SELECT
        cigar,
        op_id,
        operation,
        CASE 
            WHEN operation IN ('M', 'D', 'N', '=', 'X') THEN 
                cum_pos - len + 1 -- start position
            ELSE NULL
        END AS start_pos,
        CASE 
            WHEN operation IN ('M', 'D', 'N', '=', 'X') THEN 
                cum_pos -- end position
            ELSE NULL
        END AS end_pos
    FROM cumulative_positions
),
expanded_positions AS (
    SELECT
        cigar,
        generate_series(start_pos, end_pos) AS ref_position
    FROM reference_ranges
    WHERE operation='M'
)

SELECT cigar,flatten(list(ref_position)) FROM expanded_positions
GROUP BY cigar



