import cv2
import argparse
import os
import sys
import tqdm


def main():
    parser = argparse.ArgumentParser(
        description="Cartoonize a video using Open Computer Vision."
    )
    parser.add_argument("input", help="Path to the input video file.")
    parser.add_argument("output", help="Path to save the output video.")
    arguments = parser.parse_args()

    cartoonize(arguments.input, arguments.output)


def cartoonize(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"Error: Input file '{input_path}' not found.")
        sys.exit(1)

    capture = cv2.VideoCapture(input_path)
    if not capture.isOpened():
        print(f"Error: Could not open video '{input_path}'.")
        sys.exit(1)

    frame_width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    frames_per_second = capture.get(cv2.CAP_PROP_FPS) or 30.0
    total_frames = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))

    four_character_code = cv2.VideoWriter_fourcc(*"mp4v")
    writer = cv2.VideoWriter(
        output_path, four_character_code, frames_per_second, (frame_width, frame_height)
    )

    try:
        with tqdm.tqdm(
            total=total_frames, desc="Processing frames", unit="frame"
        ) as progress_bar:
            while True:
                success, frame = capture.read()
                if not success:
                    break

                # Convert to grayscale and apply median blur
                grayscale_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                grayscale_frame = cv2.medianBlur(grayscale_frame, 5)

                # Detect edges using adaptive thresholding
                edges = cv2.adaptiveThreshold(
                    grayscale_frame,
                    255,
                    cv2.ADAPTIVE_THRESH_MEAN_C,
                    cv2.THRESH_BINARY,
                    9,
                    9,
                )

                # Apply bilateral filter to smooth colors
                color_frame = cv2.bilateralFilter(frame, 9, 250, 250)

                # Combine edges with the color image
                cartoon_frame = cv2.bitwise_and(color_frame, color_frame, mask=edges)

                writer.write(cartoon_frame)
                progress_bar.update(1)
    finally:
        capture.release()
        writer.release()

    print(f"Done! Saved as {output_path}")


if __name__ == "__main__":
    main()
