import os
from random import shuffle
from pathlib import Path
from shutil import move
import argparse
import getpass
from tqdm import tqdm


def copy_image_and_label(img, group):
    os.makedirs(Path("dataset", group, "images", *img.parts[3:-1]), exist_ok=True)
    os.makedirs(Path("dataset", group, "labels", *img.parts[3:-1]), exist_ok=True)

    image_dst = Path("dataset", group, *img.parts[2:])
    move(img, image_dst)

    label = Path(*[p.replace("images", "labels") for p in img.parts])
    label_dst = Path("dataset", group, "labels", *img.parts[3:])

    # print(f"moving {label} to {label_dst}...")
    # print(f"\t{label} exists: {os.path.exists(label)}")
    # print(f"\t{label_dst} exists: {os.path.exists(label_dst)}")
    move(label, label_dst)


def main(args):

    # print("================")
    # print(os.getcwd())
    # print("================")

    if sum([args.frac_train, args.frac_validate, args.frac_holdout]) - 1 > 0.00001:
        raise ValueError("'frac_train', 'frac_validate' and 'frac_holdout' must sum to 1.")

    imgs = [p for p in list(Path("dataset/holdout/images").rglob("**/*.png"))]
    shuffle(imgs)
    validate_imgs_start_idx = int(len(imgs) * args.frac_train)
    holdout_imgs_idx = int(validate_imgs_start_idx + (len(imgs) * args.frac_validate))

    for img in tqdm(imgs[:validate_imgs_start_idx], description="Training Set:"):
        copy_image_and_label(img, "training")
    for img in tqdm(imgs[validate_imgs_start_idx:holdout_imgs_idx], description="Validation Set:"):
        copy_image_and_label(img, "validation")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("zoom", type=int)
    parser.add_argument("frac_train",  type=float)
    parser.add_argument("frac_validate", type=float)
    parser.add_argument("frac_holdout", type=float)
    main(parser.parse_args())
