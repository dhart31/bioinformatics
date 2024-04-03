import argparse
import matplotlib.pyplot as plt
import pandas as pd
from bokeh.plotting import figure
from bokeh.models import ColumnDataSource, HoverTool, Legend
from bokeh.io import output_file
from bokeh.plotting import figure, save


def plot_coverage_static(df, output):
    fig, ax = plt.subplots()
    for contig, data in df.groupby('contig'):
        ax.plot(data['position'], data['coverage'], label=contig)
    ax.set_xlabel('Position')
    ax.set_ylabel('Coverage')
    ax.legend()
    fig.savefig(output)

def plot_coverage_dynamic(df,output):
    source = ColumnDataSource(df)

    hover = HoverTool(tooltips=[
        ("Position", "@position"),
        ("Coverage", "@coverage"),
        ("Contig", "@contig")
    ])

    plot = figure(
        y_axis_type='log',
        tools=[hover, 'pan', 'wheel_zoom', 'box_zoom', 'reset', 'save'],
        sizing_mode = 'stretch_width'
        )
    plot.add_layout(Legend(), 'right')
    plot.line('position', 'coverage', source=source, legend_field='contig')

    plot.xaxis.axis_label = 'Position (nt)'
    plot.yaxis.axis_label = 'Coverage'
    plot.xaxis.axis_label_text_font_size = '14pt'
    plot.yaxis.axis_label_text_font_size = '14pt'
    plot.xaxis.major_label_text_font_size = '12pt'
    plot.yaxis.major_label_text_font_size = '12pt'




    output_file(output)
    save(plot)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-i','--input_bed', help='Specify a bed file with coverage information')
    parser.add_argument('-o','--output', help='Specify the output file')
    args = parser.parse_args()

    df = pd.read_csv(args.input_bed, sep='\t', header=None)
    df.columns = ['contig', 'position', 'coverage']

    if args.output.lower().endswith('.png'):
        plot_coverage_static(df, args.output)
    elif args.output.lower().endswith('.html'):
        plot_coverage_dynamic(df, args.output)
    else:
        raise ValueError('Output file extension not supported. Please specify a .png or .html file.')