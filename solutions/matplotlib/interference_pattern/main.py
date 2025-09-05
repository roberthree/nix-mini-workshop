import argparse
from .plot import create_interference_pattern


def main():
    parser = argparse.ArgumentParser(
        description="Generate a stunning interference pattern using matplotlib."
    )
    parser.add_argument(
        "--grid_limit", type=float, default=3.0, help="Range limit for both axes."
    )
    parser.add_argument(
        "--grid_points", type=int, default=500, help="Number of points along each axis."
    )
    parser.add_argument(
        "--colormap_name",
        type=str,
        default="plasma",
        help="Matplotlib colormap to use.",
    )
    parser.add_argument(
        "--output_file",
        type=str,
        default=None,
        help="Optional file path to save the image.",
    )
    args = parser.parse_args()

    create_interference_pattern(
        args.grid_limit, args.grid_points, args.colormap_name, args.output_file
    )
