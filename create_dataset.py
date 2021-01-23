import os
from random import shuffle
from pathlib import Path
from shutil import copyfile
import argparse


def copy_image_and_label(img, group):
    os.makedirs(Path("dataset", group, "images", *img.parts[2:-1]), exist_ok=True)
    os.makedirs(Path("dataset", group, "labels", *img.parts[2:-1]), exist_ok=True)

    image_dst = Path("dataset", group, *img.parts[1:])
    copyfile(img, image_dst)

    label = Path(*[p.replace("images", "labels") for p in img.parts])
    label_dst = Path("dataset", group, "labels", *img.parts[2:])

    copyfile(label, label_dst)


def main(args):

    if sum([args.frac_train, args.frac_validate, args.frac_holdout]) - 1 > 0.00001:
        raise ValueError("'frac_train', 'frac_validate' and 'frac_holdout' must sum to 1.")

    imgs = [p for p in list(Path("holdout").rglob("**/*.png"))]
    shuffle(imgs)
    validate_imgs_start_idx = int(len(imgs) * args.frac_train)
    holdout_imgs_idx = int(validate_imgs_start_idx + (len(imgs) * args.frac_validate))

    for img in imgs[:validate_imgs_start_idx]:
        copy_image_and_label(img, "training")
    for img in imgs[validate_imgs_start_idx:holdout_imgs_idx]:
        copy_image_and_label(img, "validate")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("zoom", type=int)
    parser.add_argument("frac_train",  type=float)
    parser.add_argument("frac_validate", type=float)
    parser.add_argument("frac_holdout", type=float)
    main(parser.parse_args())
