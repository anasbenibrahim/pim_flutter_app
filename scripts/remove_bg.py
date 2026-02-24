#!/usr/bin/env python3
"""
Remove black background from animated WebP.
Uses color-distance based approach to identify and remove black pixels
while preserving the Hopi character colors.
"""
from PIL import Image
import math
import sys

INPUT  = "/Users/mac/Desktop/PIM/pim_flutter_app/assets/hopi/animation videos/hopi_idle.webp"
OUTPUT = "/Users/mac/Desktop/PIM/pim_flutter_app/assets/hopi/animation videos/hopi_idle_transparent.webp"

# Threshold: pixels with RGB values all below this are considered "black background"
BLACK_THRESHOLD = 35
# Transition zone for soft edges (anti-aliasing)
SOFT_EDGE = 25

def remove_black_bg(frame):
    """Remove black background from a single frame."""
    frame = frame.convert("RGBA")
    pixels = frame.load()
    w, h = frame.size
    
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            
            # Calculate max channel value — pure black has all channels near 0
            max_channel = max(r, g, b)
            
            if max_channel < BLACK_THRESHOLD:
                # Pure black → fully transparent
                pixels[x, y] = (0, 0, 0, 0)
            elif max_channel < BLACK_THRESHOLD + SOFT_EDGE:
                # Transition zone → soft edge (partial transparency)
                # This prevents hard aliased edges
                opacity = int(((max_channel - BLACK_THRESHOLD) / SOFT_EDGE) * 255)
                # Boost the color to compensate for semi-transparency
                factor = 255.0 / max(max_channel, 1)
                new_r = min(int(r * factor), 255)
                new_g = min(int(g * factor), 255)
                new_b = min(int(b * factor), 255)
                pixels[x, y] = (new_r, new_g, new_b, opacity)
    
    return frame

def main():
    print(f"Loading: {INPUT}")
    img = Image.open(INPUT)
    
    frames = []
    durations = []
    
    n_frames = getattr(img, 'n_frames', 1)
    print(f"Total frames: {n_frames}")
    
    for i in range(n_frames):
        img.seek(i)
        duration = img.info.get('duration', 100)
        durations.append(duration)
        
        frame = img.copy()
        processed = remove_black_bg(frame)
        frames.append(processed)
        
        if (i + 1) % 5 == 0 or i == 0:
            print(f"  Processed frame {i+1}/{n_frames}")
    
    print(f"Saving {len(frames)} frames to: {OUTPUT}")
    frames[0].save(
        OUTPUT,
        format='WEBP',
        save_all=True,
        append_images=frames[1:],
        duration=durations,
        loop=0,
        quality=90,
        lossless=True,
    )
    
    # Get file sizes
    import os
    orig_size = os.path.getsize(INPUT) / 1024
    new_size = os.path.getsize(OUTPUT) / 1024
    print(f"\nDone!")
    print(f"  Original: {orig_size:.0f} KB")
    print(f"  Transparent: {new_size:.0f} KB")

if __name__ == "__main__":
    main()
