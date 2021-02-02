from glob import glob

from PIL import Image, ImageFont, ImageDraw

folders = ["compare", "compare-training", "compare-validation"]

i = 0
for folder in folders:
    for img_path in glob(f"{folder}/compare/17/**/*.png"):
        img = Image.open(img_path, mode="r")
        draw = ImageDraw.Draw(img)
        font = ImageFont.truetype("open-sans/OpenSans-Regular.ttf", 32)
        draw.text((0, 0), folder, (255, 255, 255), font=font)
        img.save(f'all_images/{folder}-{str(i).zfill(4)}.png')
        i += 1
        print(i)