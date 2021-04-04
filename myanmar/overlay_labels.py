import os
from PIL import Image
from pathlib import Path
from glob import glob
import shutil
from tqdm import tqdm

TRAINING_COLOR = (229, 94, 94, 255)
BACKGROUND_COLOR = (86, 184, 129, 255)
OPACITY = 0.5

shutil.rmtree(Path("holdout", "overlay", "17"))
shutil.copytree(
    Path("holdout", "images", "17"),
    Path("holdout", "overlay", "17"),
    ignore=lambda dir, files: [f for f in files if os.path.isfile(os.path.join(dir, f))]
)

for img_path in tqdm(glob("holdout/images/17/**/*.png")):
    img = Image.open(img_path).convert("RGBA")
    label = Image.open(img_path.replace("images", "labels")).convert("RGBA")

    pixels = label.load()
    width, height = label.size
    for y in range(height):
        for x in range(width):
            if pixels[x, y] == BACKGROUND_COLOR:
                pixels[x, y] = (255, 255, 255, 0)
            else:
                pixels[x, y] = (*tuple(x for x in TRAINING_COLOR[:-1]), round(OPACITY * 255))

    out = Image.new("RGBA", img.size)
    out = Image.alpha_composite(out, img)
    out = Image.alpha_composite(out, label)

    # out.show()
    # label.show()
    out.save(img_path.replace("images", "overlay"))
