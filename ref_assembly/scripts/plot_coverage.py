import os
import argparse
import matplotlib.pyplot as plt
import pandas as pd
from bokeh.plotting import figure
from bokeh.models import ColumnDataSource, HoverTool, Legend
from bokeh.io import output_file
from bokeh.plotting import figure, save
from pandas import __version__ as pd_version
from bokeh import __version__ as bokeh_version
from matplotlib import __version__ as mpl_version


def plot_coverage_static(df, output):
    fig, ax = plt.subplots()
    for contig, data in df.groupby('sample'):
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
        ("Sample", "@sample")
    ])

    plot = figure(
        y_axis_type='log',
        tools=[hover, 'pan', 'wheel_zoom', 'box_zoom', 'reset', 'save'],
        sizing_mode = 'stretch_width'
        )
    plot.add_layout(Legend(), 'right')
    plot.line('position', 'coverage', source=source, legend_field='sample')

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
    parser.add_argument('-i','--input_files',
                        help='Specify a bed file with coverage information',
                        nargs='+')
    parser.add_argument('-o','--output', help='Specify the output file')
    parser.add_argument('-v','--version',help='Specify a yaml file with version information')
    args = parser.parse_args()

    dfs = []
    for input_bed in args.input_files:
        df = pd.read_csv(input_bed, sep='\t', header=None)
        df.columns = ['genome', 'position', 'coverage']
        sample_name = os.path.splitext(os.path.basename(input_bed))[0]
        df['sample'] = sample_name
        dfs.append(df)

    if args.output.lower().endswith('.png'):
        plot_coverage_static(df, args.output)
    elif args.output.lower().endswith('.html'):
        plot_coverage_dynamic(df, args.output)
    else:
        raise ValueError('Output file extension not supported. Please specify a .png or .html file.')
    
    if args.version:
        with open(args.version, 'a') as f:
            f.write(f'pandas: {pd_version}\n')
            f.write(f'bokeh: {bokeh_version}\n')
            f.write(f'matplotlib: {mpl_version}\n')