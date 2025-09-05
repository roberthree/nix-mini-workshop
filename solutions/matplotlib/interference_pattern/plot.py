import numpy as np
import matplotlib.pyplot as plt


def create_interference_pattern(
    grid_limit=3.0, grid_points=500, colormap_name="plasma", output_file=None
):
    """
    Create and display a colorful interference pattern using sine and cosine functions.

    Parameters:
        grid_limit (float): Range limit for both x and y axes.
        grid_points (int): Number of points along each axis.
        colormap_name (str): Matplotlib colormap to use.
        output_file (str or None): If provided, save the image to this file path.
    """
    x_values = np.linspace(-grid_limit, grid_limit, grid_points)
    y_values = np.linspace(-grid_limit, grid_limit, grid_points)
    X_grid, Y_grid = np.meshgrid(x_values, y_values)

    Z_values = np.sin(X_grid**2 + Y_grid**2) + np.cos(2 * X_grid + Y_grid)

    plt.figure(figsize=(8, 8))
    plt.imshow(
        Z_values,
        cmap=colormap_name,
        extent=[-grid_limit, grid_limit, -grid_limit, grid_limit],
        origin="lower",
    )
    plt.colorbar(label="Intensity")
    plt.title(
        "Stunning Interference Pattern",
        fontsize=16,
        fontweight="bold",
        color="white",
        pad=20,
    )
    plt.axis("off")
    plt.tight_layout()

    if output_file:
        plt.savefig(output_file, dpi=300, bbox_inches="tight", facecolor="black")
        print(f"Pattern saved as {output_file}")
    else:
        plt.show()
