#!/usr/bin/python3

import argparse
import logging
import os
import sys
import json
import shutil
import colorsys
import subprocess
import re
import hashlib
import copy

HOME = os.getenv("HOME", os.getenv("USERPROFILE"))
XDG_CACHE_DIR = os.getenv("XDG_CACHE_HOME", os.path.join(HOME, ".cache"))
XDG_CONF_DIR = os.getenv("XDG_CONFIG_HOME", os.path.join(HOME, ".config"))
CACHE_DIR = os.getenv("PYWAL_CACHE_DIR", os.path.join(XDG_CACHE_DIR, "wal"))

has_fcntl = False
fcntl_warning = ""

try:
    import fcntl

    has_fcntl = True
except ImportError:
    fcntl_warning = "{}, {}".format(
        "can't skip blocking io in current platform",
        "program could hang indefinitely",
    )


class Color:
    """Color formats."""

    alpha_num = "100"
    passed_alpha_num = None

    def __init__(self, hex_color):
        self.hex_color = hex_color

    def __str__(self):
        return self.hex_color

    @property
    def rgb(self):
        """Convert a hex color to rgb."""
        return "%s,%s,%s" % (*hex_to_rgb(self.hex_color),)

    @property
    def rgbspace(self):
        """Convert a hex color to rgb separated by spaces."""
        return "%s %s %s" % (*hex_to_rgb(self.hex_color),)

    @property
    def xrgba(self):
        """Convert a hex color to xrdb rgba."""
        return hex_to_xrgba(self.hex_color)

    @property
    def rgba(self):
        """Convert a hex color to rgba."""
        return "rgba(%s,%s,%s,%s)" % (
            *hex_to_rgb(self.hex_color),
            self.alpha_dec,
        )

    @property
    def hex_argb(self):
        """Convert an alpha hex color to argb hex."""
        al_val = alpha_integrify(self.alpha_num)
        return "#%02X%s" % (
            int(int(al_val) * 255 / 100),
            self.hex_color[1:],
        )

    @property
    def alpha(self):
        """Add URxvt alpha value to color."""
        al_val = alpha_integrify(self.alpha_num)
        return "[%s]%s" % (al_val, self.hex_color)

    @property
    def alpha_dec(self):
        """Export the alpha value as a decimal number in [0, 1]."""
        al_val = alpha_integrify(self.alpha_num)
        return int(al_val) / 100

    @property
    def alpha_hex(self):
        """Export the alpha value as a hexdecimal number in [00, FF]."""
        al_val = alpha_integrify(self.alpha_num)
        return "%02X" % (int(int(al_val) * 255 / 100))

    @property
    def decimal(self):
        """Export color in decimal."""
        return "%s%s" % ("#", int(self.hex_color[1:], 16))

    @property
    def decimal_strip(self):
        """Strip '#' from decimal color."""
        return int(self.hex_color[1:], 16)

    @property
    def octal(self):
        """Export color in octal."""
        return "%s%s" % ("#", oct(int(self.hex_color[1:], 16))[2:])

    @property
    def octal_strip(self):
        """Strip '#' from octal color."""
        return oct(int(self.hex_color[1:], 16))[2:]

    @property
    def strip(self):
        """Strip '#' from color."""
        return self.hex_color[1:]

    @property
    def red(self):
        """Red value as float between 0 and 1."""
        return "%.3f" % (hex_to_rgb(self.hex_color)[0] / 255.0)

    @property
    def green(self):
        """Green value as float between 0 and 1."""
        return "%.3f" % (hex_to_rgb(self.hex_color)[1] / 255.0)

    @property
    def blue(self):
        """Blue value as float between 0 and 1."""
        return "%.3f" % (hex_to_rgb(self.hex_color)[2] / 255.0)

    @property
    def red_hex(self):
        """Red value as hex."""
        return "%s" % (self.hex_color)[1:3]

    @property
    def green_hex(self):
        """Green value as hex."""
        return "%s" % (self.hex_color)[3:5]

    @property
    def blue_hex(self):
        """Blue value as hex."""
        return "%s" % (self.hex_color)[5:]

    @property
    def red_dec(self):
        """Red value as decimal."""
        return "%s" % hex_to_rgb(self.hex_color)[0]

    @property
    def green_dec(self):
        """Green value as decimal."""
        return "%s" % hex_to_rgb(self.hex_color)[1]

    @property
    def blue_dec(self):
        """Blue value as decimal."""
        return "%s" % hex_to_rgb(self.hex_color)[2]

    @property
    def w3_luminance(self):
        """Luminance value of the color according to W3 formula"""

        color_channels = [float(self.red), float(self.green), float(self.blue)]
        for index, channel in enumerate(color_channels):
            if channel <= 0.04045:
                color_channels[index] = channel / 12.92
            else:
                color_channels[index] = ((channel + 0.055) / 1.055) ** 2.4

        return (
            (0.2126 * color_channels[0])
            + (0.7152 * color_channels[1])
            + (0.0722 * color_channels[2])
        )

    def lighten(self, percent):
        """Lighten color by percent."""
        percent = float(re.sub(r"[\D\.]", "", str(percent)))
        return Color(lighten_color(self.hex_color, percent / 100))

    def darken(self, percent):
        """Darken color by percent."""
        percent = float(re.sub(r"[\D\.]", "", str(percent)))
        return Color(darken_color(self.hex_color, percent / 100))

    def saturate(self, percent):
        """Saturate a color."""
        percent = float(re.sub(r"[\D\.]", "", str(percent)))
        return Color(saturate_color(self.hex_color, percent / 100))

    def adjust_alpha(self, alpha="100"):
        adjusted = copy.copy(self)
        adjusted.alpha_num = alpha
        return adjusted


def save_file(data, export_file):
    """Write data to a file."""
    create_dir(os.path.dirname(export_file))

    if has_fcntl:
        try:
            with open(export_file, "w") as file:
                # Get the current flags and add non-blocking mode
                # to skip TTYs suspended by Flow Control
                # https://www.gnu.org/software/libc/manual/html_node/Getting-File-Status-Flags.html
                # https://www.gnu.org/software/libc/manual/html_node/Open_002dtime-Flags.html
                flags = fcntl.fcntl(file, fcntl.F_GETFL)
                fcntl.fcntl(file, fcntl.F_SETFL, flags | os.O_NONBLOCK)
                file.write(data)
        except PermissionError:
            logging.warning("Couldn't write to %s.", export_file)
        except BlockingIOError:
            logging.warning(
                "Couldn't write to %s, not accepting data", export_file
            )
    else:
        try:
            with open(export_file, "w") as file:
                file.write(data)
        except PermissionError:
            logging.warning("Couldn't write to %s.", export_file)


def save_file_json(data, export_file):
    """Write data to a json file."""
    create_dir(os.path.dirname(export_file))

    with open(export_file, "w") as file:
        json.dump(data, file, indent=4)


def get_img_checksum(img):
    checksum = hashlib.new("md5", usedforsecurity=False)
    with open(img, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            checksum.update(chunk)
    return checksum.hexdigest()


def create_dir(directory):
    """Alias to create the cache dir."""
    os.makedirs(directory, exist_ok=True)


def setup_logging():
    """Logging config."""
    logging.basicConfig(
        format=(
            "[%(levelname)s\033[0m] "
            "\033[1;31m%(module)s\033[0m: "
            "%(message)s"
        ),
        level=logging.INFO,
        stream=sys.stdout,
    )
    logging.addLevelName(logging.ERROR, "\033[1;31mE")
    logging.addLevelName(logging.INFO, "\033[1;32mI")
    logging.addLevelName(logging.WARNING, "\033[1;33mW")


def hex_to_rgb(color):
    """Convert a hex color to rgb."""
    return tuple(bytes.fromhex(color.strip("#")))


def hex_to_xrgba(color):
    """Convert a hex color to xrdb rgba."""
    col = color.lower().strip("#")
    return "%s%s/%s%s/%s%s/ff" % (*col,)


def rgb_to_hex(color):
    """Convert an rgb color to hex."""
    return "#%02x%02x%02x" % (*color,)


def darken_color(color, amount):
    """Darken a hex color."""
    color = [int(col * (1 - amount)) for col in hex_to_rgb(color)]
    return rgb_to_hex(color)


def lighten_color(color, amount):
    """Lighten a hex color."""
    color = [int(col + (255 - col) * amount) for col in hex_to_rgb(color)]
    return rgb_to_hex(color)


def alpha_integrify(alpha_value):
    """
    ensure the alpha string is an int between 0 and 100

    return: int string between 0 an 100
    """
    # could be a string containing a float like 0.7
    a = float(alpha_value)
    if a < 0:
        a = abs(a)
    if a < 1:
        a = a * 100
    if a > 100:
        a = 100
    a = int(a)
    a = str(a)
    return a


def saturate_color(color, amount):
    """Change saturation of a hex color to passed value.

    new_saturation = amount"""
    r, g, b = hex_to_rgb(color)
    r, g, b = [x / 255.0 for x in (r, g, b)]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    s = amount
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    r, g, b = [x * 255.0 for x in (r, g, b)]

    return rgb_to_hex((int(r), int(g), int(b)))


def add_saturation(color, amount):
    """Add saturation to a hex color.

    new_saturation = color_saturation + amount"""
    r, g, b = hex_to_rgb(color)
    r, g, b = [x / 255.0 for x in (r, g, b)]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    s = s + amount
    if s > 1.0:
        s = 1
    if s < -1.0:
        s = -1
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    r, g, b = [x * 255.0 for x in (r, g, b)]

    return rgb_to_hex((int(r), int(g), int(b)))


def disown(cmd):
    """Call a system command in the background,
    disown it and hide it's output."""
    subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def util_has_im():
    """Check to see if the user has im installed."""
    if shutil.which("magick"):
        return "magick"

    if shutil.which("convert"):
        return "convert"

    logging.error("Problem running image averaging command.")
    logging.error("Imagemagick wasn't found on your system.")
    sys.exit(1)


def image_average_color(img):
    """Get the average color of an image using imagemagick
    by resizing to 1x1"""
    # Attempt to run the imagemagick command
    # Resizes to 1x1 and enumerates all pixel data (one pixel) to stdout
    # Command adapted from a stackoverflow thread, but tinkered with because the
    # thread was a decade old:
    # # https://stackoverflow.com/questions/25488338/how-to-find-average-color-of-an-image-with-imagemagick
    cmd_flags = [
        "-resize",
        "1x1!",
        "-format",
        '"%[fx:int(255*r+.5)],%[fx:int(255*g+.5)],%[fx:int(255*b+.5)]"',
        "txt:-",
    ]
    magick_command = util_has_im()
    try:
        magick_output = subprocess.run(
            [magick_command, img] + cmd_flags, stdout=subprocess.PIPE
        )
    except subprocess.CalledProcessError as Err:
        logging.error(
            "Problem running image averaging command. Is imagemagick installed?"
        )
        logging.error("Imagemagick error: %s", Err)
        return ""

    # Regex hex code from the command output
    return re.search("#[0-9A-Fa-f]{6}", magick_output.stdout.decode("utf-8"))[0]


def get_args():
    """Get the script arguments."""
    arg = argparse.ArgumentParser()
    
    arg.add_argument(
        "--cols16",
        metavar="method",
        required=False,
        nargs="?",
        default=False,
        const="darken",
        choices=["darken", "lighten", "dual"],
        help='Use 16 color output "darken", "lighten" or "dual" default: darken',
    )

    arg.add_argument(
        "--saturate", 
        metavar="-1.0 - 1.0", 
        help="Set the color saturation."
    )

    arg.add_argument(
        "-i",
        metavar='"/path/to/img.jpg"',
        help="Which image or directory to use.",
    )

    arg.add_argument(
        "-l", 
        action="store_true", 
        help="Generate a light colorscheme."
    )

    arg.add_argument(
        "--contrast",
        metavar="1.0-21.0",
        required=False,
        type=float,
        nargs="?",
        help="Specify a minimum contrast ratio.",
    )

    return arg


def parse_args_exit(parser):
    """Process args that exit."""
    args = parser.parse_args()

    if len(sys.argv) <= 1:
        parser.print_help()
        sys.exit(1)

def getimage(img, cache_dir=CACHE_DIR, iterative=False, recursive=False):
    """Validate image input."""
    if os.path.isfile(img):
        wal_img = img

    else:
        logging.error("No valid image file found.")
        sys.exit(1)

    wal_img = os.path.abspath(wal_img)

    # Cache the image file path.
    save_file(wal_img, os.path.join(cache_dir, "wal"))

    logging.info("Using image \033[1;37m%s\033[0m.", os.path.basename(wal_img))
    return wal_img

def parse_args(parser):
    """Process args."""
    args = parser.parse_args()

    if args.i:
        image_file = getimage(args.i)
        colors_plain = getcolors(
            image_file,
            args.l,
            sat=args.saturate,
            c16=args.cols16,
            cst=args.contrast,
        )

        # Export the colors
        createcolorsjsonfile(colors_plain)


def normalize_img_path(img: str):
    """Normalizes the image path for output."""
    if os.name == "nt":
        # On Windows, the JSON.dump ends up outputting un-escaped backslash
        # breaking the ability to read colors.json. Windows supports forward
        # slash, so we can use that for now
        return img.replace("\\", "/")
    return img


def colors_to_dict(colors, img):
    """Convert list of colors to pywal format."""
    return {
        "checksum": get_img_checksum(img),
        "wallpaper": normalize_img_path(img),
        "alpha": Color.alpha_num,
        "special": {
            "background": colors[0],
            "foreground": colors[15],
            "cursor": colors[15],
        },
        "colors": {
            "color0": colors[0],
            "color1": colors[1],
            "color2": colors[2],
            "color3": colors[3],
            "color4": colors[4],
            "color5": colors[5],
            "color6": colors[6],
            "color7": colors[7],
            "color8": colors[8],
            "color9": colors[9],
            "color10": colors[10],
            "color11": colors[11],
            "color12": colors[12],
            "color13": colors[13],
            "color14": colors[14],
            "color15": colors[15],
        },
    }


def get_color_names_list(colors_dict):
    ret_list = []
    # detect dict type
    if "color0" in colors_dict:
        ret_list = [
                "color0", "color1", "color2", "color3",
                "color4", "color5", "color6", "color7",
                "color8", "color9", "color10", "color11",
                "color12", "color13", "color14", "color15",
              ]
    else:
        ret_list = [
                0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
              ]
    return ret_list


def shade_darken(colors, light):
    k_v = []
    k_v = get_color_names_list(colors)
    if light:
        colors[k_v[1]] = darken_color(colors[k_v[1]], 0.25)
        colors[k_v[2]] = darken_color(colors[k_v[2]], 0.25)
        colors[k_v[3]] = darken_color(colors[k_v[3]], 0.25)
        colors[k_v[4]] = darken_color(colors[k_v[4]], 0.25)
        colors[k_v[5]] = darken_color(colors[k_v[5]], 0.25)
        colors[k_v[6]] = darken_color(colors[k_v[6]], 0.25)
    else:
        colors[k_v[1]] = darken_color(colors[k_v[1]], 0.25)
        colors[k_v[2]] = darken_color(colors[k_v[2]], 0.25)
        colors[k_v[3]] = darken_color(colors[k_v[3]], 0.25)
        colors[k_v[4]] = darken_color(colors[k_v[4]], 0.25)
        colors[k_v[5]] = darken_color(colors[k_v[5]], 0.25)
        colors[k_v[6]] = darken_color(colors[k_v[6]], 0.25)


def shade_lighten(colors, light):
    k_v = []
    k_v = get_color_names_list(colors)
    if light:
        colors[k_v[9]] = lighten_color(colors[k_v[1]], 0.25)
        colors[k_v[10]] = lighten_color(colors[k_v[2]], 0.25)
        colors[k_v[11]] = lighten_color(colors[k_v[3]], 0.25)
        colors[k_v[12]] = lighten_color(colors[k_v[4]], 0.25)
        colors[k_v[13]] = lighten_color(colors[k_v[5]], 0.25)
        colors[k_v[14]] = lighten_color(colors[k_v[6]], 0.25)
    else:
        colors[k_v[9]] = lighten_color(colors[k_v[1]], 0.25)
        colors[k_v[10]] = lighten_color(colors[k_v[2]], 0.25)
        colors[k_v[11]] = lighten_color(colors[k_v[3]], 0.25)
        colors[k_v[12]] = lighten_color(colors[k_v[4]], 0.25)
        colors[k_v[13]] = lighten_color(colors[k_v[5]], 0.25)
        colors[k_v[14]] = lighten_color(colors[k_v[6]], 0.25)
        for i in range(9, 15):
            colors[k_v[i]] = saturate_color(colors[k_v[i]], 0.40)


def shade_16(colors, light, cols16):
    """Generic 16 color shading
    this function will apply the 16 color shading
    to any color dict it is passed

    colors: dict
    light:  boolean - werether the colorscheme is light
    cols16: str [lighten|darken] - method to generate the shades"""

    k_v = []
    k_v = get_color_names_list(colors)

    if cols16:
        if light:
            colors[k_v[7]] = darken_color(colors[k_v[0]], 0.50)
            colors[k_v[8]] = darken_color(colors[k_v[0]], 0.25)
            colors[k_v[15]] = darken_color(colors[k_v[0]], 0.75)
            if cols16 == "lighten" or cols16 == "dual":
                shade_lighten(colors, light)
            if cols16 == "darken" or cols16 == "dual":
                shade_darken(colors, light)
        else:
            colors[k_v[7]] = lighten_color(colors[k_v[0]], 0.55)
            colors[k_v[7]] = saturate_color(colors[k_v[7]], 0.05)
            colors[k_v[8]] = lighten_color(colors[k_v[0]], 0.35)
            colors[k_v[8]] = saturate_color(colors[k_v[8]], 0.10)
            colors[k_v[15]] = lighten_color(colors[k_v[0]], 0.75)
            if cols16 == "lighten" or cols16 == "dual":
                shade_lighten(colors, light)
            if cols16 == "darken" or cols16 == "dual":
                shade_darken(colors, light)


def generic_adjust(colors, light, **kwargs):
    """Generic color adjustment for themers.
    :keyword-args:
    -    c16 - [ "lighten" | "darken" ]
    """
    if "c16" in kwargs:
        cols16 = kwargs["c16"]
    else:
        cols16 = False

    if light:
        for color in colors:
            color = saturate_color(color, 0.60)
            color = darken_color(color, 0.5)

        colors[0] = lighten_color(colors[0], 0.95)
        if cols16:
            shade_16(colors, light, cols16)
        else:
            colors[7] = darken_color(colors[0], 0.75)
            colors[8] = darken_color(colors[0], 0.25)
            colors[15] = colors[7]

    else:
        if colors[0][1] != "0":  # the color may already be dark enough
            colors[0] = darken_color(colors[0], 0.40)  # just a bit darker

        saturate_more = False
        if colors[0][1] == "0":  # the color may not be saturated enough
            saturate_more = True
        if colors[0][3] == "0":  # the color may not be saturated enough
            saturate_more = True
        if colors[0][5] == "0":  # the color may not be saturated enough
            saturate_more = True

        if saturate_more:
            colors[0] = lighten_color(colors[0], 0.03)
            colors[0] = saturate_color(colors[0], 0.40)

        if cols16:
            shade_16(colors, light, cols16)
        else:
            colors[7] = lighten_color(colors[0], 0.75)
            colors[8] = lighten_color(colors[0], 0.35)
            colors[8] = saturate_color(colors[8], 0.10)
            colors[15] = colors[7]

    return colors


def saturate_colors(colors, amount):
    """Saturate all colors."""
    if amount and (float(amount) <= 1.0 and float(amount) >= -1.0):
        for i, _ in enumerate(colors):
            if i not in [7, 15]:
                colors[i] = add_saturation(colors[i], float(amount))

    return colors


def ensure_contrast(colors, contrast, light, image):
    """Ensure user-specified W3 contrast of colors
    depending on dark or light theme."""
    # If no contrast checking was specified, do nothing
    if not contrast or contrast == "":
        return colors

    # Contrast must be within a predefined range
    if float(contrast) < 1 or float(contrast) > 21:
        logging.error("Specified contrast ratio is too extreme")
        return colors

    # Get the image background color
    background_color = Color(image_average_color(image))
    background_luminance = background_color.w3_luminance

    # Calculate the required W3 luminance for the desired contrast ratio
    # This will modify all of the colors to be brighter or darker than the
    # background image depending on whether the user has specified for a
    # dark or light theme
    try:
        if light:
            luminance_desired = (background_luminance + 0.05) / float(
                contrast
            ) - 0.05
        else:
            luminance_desired = (background_luminance + 0.05) * float(
                contrast
            ) - 0.05
    except ValueError:
        logging.error("ensure_contrast(): Contrast valued could not be parsed")
        return colors

    if luminance_desired >= 0.99:
        print("Can't contrast this palette without changing colors to white")
        return colors
    if luminance_desired <= 0.01:
        print("Can't contrast this palette without changing colors to black")
        return colors

    # Determine which colors should be modified / checked
    # ! For the time being this is just going to modify all the colors except
    # 0 and 15
    colors_to_contrast = range(1, 15)

    # Modify colors
    for index in colors_to_contrast:
        color = Color(colors[index])

        # If the color already has sufficient contrast, do nothing
        if light and color.w3_luminance <= luminance_desired:
            continue
        elif color.w3_luminance >= luminance_desired:
            continue

        h, s, v = colorsys.rgb_to_hsv(
            float(color.red), float(color.green), float(color.blue)
        )

        # Determine how to modify the color based on its HSV characteristics

        # If the color is to be lighter than background, and the HSV color
        # with value 1 has sufficient luminance, adjust by increasing value
        if (
            not light
            and Color(
                rgb_to_hex(
                    [
                        int(channel * 255)
                        for channel in colorsys.hsv_to_rgb(h, s, 1)
                    ]
                )
            ).w3_luminance
            >= luminance_desired
        ):
            colors[index] = binary_luminance_adjust(
                luminance_desired, h, s, s, v, 1
            )
        # If the color is to be lighter than background and increasing value
        # to 1 doesn't produce the desired luminance, additionally decrease
        # saturation
        elif not light:
            colors[index] = binary_luminance_adjust(
                luminance_desired, h, 0, s, 1, 1
            )
        # If the color is to be darker than background, produce desired
        # luminance by decreasing value, and raising saturation
        else:
            colors[index] = binary_luminance_adjust(
                luminance_desired, h, s, 1, 0, v
            )

    return colors


def binary_luminance_adjust(
    luminance_desired, hue, s_min, s_max, v_min, v_max, iterations=10
):
    """Use a binary method to adjust a color's value and/or
    saturation to produce the desired luminance"""
    for i in range(iterations):
        # Obtain a new color by averaging saturation and value
        s = (s_min + s_max) / 2
        v = (v_min + v_max) / 2

        # Compare the luminance of this color to the target luminance
        # If the color is too light, clamp the minimum saturation
        # and maximum value
        if (
            Color(
                rgb_to_hex(
                    [
                        int(channel * 255)
                        for channel in colorsys.hsv_to_rgb(hue, s, v)
                    ]
                )
            ).w3_luminance
            >= luminance_desired
        ):
            s_min = s
            v_max = v
        # If the color is too dark, clamp the maximum saturation
        # and minimum value
        else:
            s_max = s
            v_min = v

    return rgb_to_hex(
        [int(channel * 255) for channel in colorsys.hsv_to_rgb(hue, s, v)]
    )


def cache_fname(img, light, cache_dir, sat="", **kwargs):
    """Create the cache file name.
    :keyword-args:
    -    c16: use 16 colors through specified method - [ "lighten" | "darken" ]
    -    cst: palette contrast ratio - float
    """
    color_type = "light" if light else "dark"
    if "c16" in kwargs:
        cols16 = kwargs["c16"]
    else:
        cols16 = False
    if "cst" in kwargs:
        contrast = kwargs["cst"]
    else:
        contrast = False
    color_num = "16" if cols16 else "9"
    file_name = re.sub("[/|\\|.]", "_", img)
    file_size = os.path.getsize(img)

    if cols16 and contrast:
        file_parts = [
            file_name,
            color_num,
            cols16,
            color_type,
            sat,
            contrast,
            file_size,
        ]
        return [
            cache_dir,
            "schemes",
            "%s_%s_%s_%s_%s_%s_%s.json" % (*file_parts,),
        ]
    if cols16 and (not contrast):
        file_parts = [
            file_name,
            color_num,
            cols16,
            color_type,
            sat,
            file_size,
        ]
        return [
            cache_dir,
            "schemes",
            "%s_%s_%s_%s_%s_%s.json" % (*file_parts,),
        ]
    if (not cols16) and contrast:
        file_parts = [
            file_name,
            color_type,
            sat,
            contrast,
            file_size,
        ]
        return [
            cache_dir,
            "schemes",
            "%s_%s_%s_%s_%s.json" % (*file_parts,),
        ]
    else:
        file_parts = [
            file_name,
            color_type,
            sat,
            file_size,
        ]
        return [
            cache_dir,
            "schemes",
            "%s_%s_%s_%s.json" % (*file_parts,),
        ]


def palette():
    """Generate a palette from the colors."""
    for i in range(0, 16):
        if i % 8 == 0:
            print()

        if i > 7:
            i = "8;5;%s" % i

        print("\033[4%sm%s\033[0m" % (i, " " * (80 // 20)), end="")

    print("\n")


def imagemagick(color_count, img, magick_command):
    """Call Imagemagick to generate a scheme."""
    flags = [
        "-resize",
        "25%",
        "-colors",
        str(color_count),
        "-unique-colors",
        "txt:-",
    ]
    img += "[0]"

    try:
        output = subprocess.check_output(
            [*magick_command.split(), img, *flags], stderr=subprocess.STDOUT
        ).splitlines()
    except subprocess.CalledProcessError as Err:
        logging.error("Imagemagick error: %s", Err)
        logging.error(
            "IM 7 disables stdout by default, check the manual or wiki to fix."
        )
        sys.exit(1)
    return output


def has_im():
    """Check to see if the user has im installed."""
    magick_commands = []

    if shutil.which("magick"):
        magick_commands.extend(["magick", "magick convert"])

    if shutil.which("convert"):
        magick_commands.append("convert")

    if len(magick_commands) > 0:
        return magick_commands

    logging.error("Imagemagick wasn't found on your system.")
    logging.error("Try another backend. (wal --backend)")
    sys.exit(1)


def gen_colors_with_command(
        img, magick_command, beginning_color_count=16, iteration_count=20
        ):
    """Iteratively attempt to generate a 16-color palette
    using a specific Imagemagick command."""
    hex_pattern = re.compile(r"#[A-F0-9]{6}", re.IGNORECASE)

    max_color_count = beginning_color_count + iteration_count - 1
    for color_count in range(
            beginning_color_count, beginning_color_count + iteration_count
            ):
        raw_output = imagemagick(color_count, img, magick_command)
        hex_colors = [
            hex_pattern.search(str(col)).group()
            for col in raw_output
            if hex_pattern.search(str(col))
        ]

        if len(hex_colors) >= 16:
            break

        if color_count < max_color_count:
            logging.warning(
                    "Imagemagick couldn't generate a "
                    f"palette with {magick_command}."
                    )
            logging.warning(
                    f"Trying a larger palette size {color_count}."
                    )
        else:
            logging.error(
                    "Imagemagick couldn't generate a suitable palette "
                    f"with {magick_command}."
                    )
            logging.warning(
                    "Will try to do palette concatenation, "
                    "good results not guaranteed!"
                    )
            while len(hex_colors) < 16:
                hex_colors.extend(hex_colors)
    return hex_colors


def gen_colors(img):
    """Try each Imagemagick command until a color palette
    is successfully generated."""
    magick_commands = has_im()

    for magick_command in magick_commands:
        logging.debug(f"Trying {magick_command}...")

        hex_colors = gen_colors_with_command(img, magick_command)

        if not hex_colors:
            logging.warning(
                    f"Failed to generate colors with {magick_command}."
                    )
            continue

        return hex_colors

    raise RuntimeError(
            "Failed to generate color palette from "
            f"{img} with these commands: {magick_commands}"
            )


def adjust(cols, light, **kwargs):
    """Adjust the generated colors and store them in a dict that
    we will later save in json format.
    :keyword-args:
    -    c16: use 16 colors through specified method - [ "lighten" | "darken" ]
    """
    if "c16" in kwargs:
        cols16 = kwargs["c16"]
    else:
        cols16 = False
    raw_colors = cols[:1] + cols[8:16] + cols[8:-1]

    return generic_adjust(raw_colors, light, c16=cols16)


def getwal(img, light=False, **kwargs):
    """Get colorscheme.
    :keyword-args:
    -    c16: use 16 colors through specified method - [ "lighten" | "darken" ]
    """
    if "c16" in kwargs:
        cols16 = kwargs["c16"]
    else:
        cols16 = False
    colors = gen_colors(img)
    # it is possible we could have picked garbage data
    garbage = "# Image"
    if garbage in colors:
        colors.remove(garbage)
    return adjust(colors, light, c16=cols16)


def getcolors(
    img,
    light=False,
    cache_dir=CACHE_DIR,
    sat="",
    **kwargs,
):
    """Generate a palette.
    :keyword-args:
    -    c16: use 16 colors through specified method - [ "lighten" | "darken" ]
    -    cst: apply contrast ratio to palette        - float
    """
    if "c16" in kwargs:
        cols16 = kwargs["c16"]
    else:
        cols16 = False
    if "cst" in kwargs:
        contrast = kwargs["cst"]
    else:
        contrast = ""

    # home_dylan_img_jpg_backend_1.2.2.json
    if not contrast or contrast == "":
        cache_name = cache_fname(
            img, light, cache_dir, sat,
            c16=cols16
        )
    else:
        cache_name = cache_fname(
            img, light, cache_dir, sat,
            c16=cols16, cst=float(contrast)
        )

    cache_file = os.path.join(*cache_name)

    logging.info("Generating a colorscheme.")
    
    colors = getwal(img, light, c16=cols16)

    colors = saturate_colors(colors, sat)
    colors = ensure_contrast(colors, contrast, light, img)
    colors_dict = colors_to_dict(colors, img)

    colors = colors_to_dict(colors, img)

    save_file_json(colors, cache_file)
    logging.info("Generation complete.")

    return colors

def generate_color_images(colors, destdir):
    """Save palette colors as an image."""
    if shutil.which("ultrakill-wal"):
        disown(["ultrakill-wal"])
    else:
        # Dynamically import PIL to keep it as an optional dependency.
        try:
            from PIL import Image

            img = Image.new("RGB", (16, 1))
            for i, color in enumerate(colors["colors"].values()):
                img.paste(Image.new("RGB", (1, 1), color), (i, 0))
            img.save(os.path.join(destdir, "colors.png"))
        except ImportError:
            pass


def createcolorsjsonfile(colors, output_dir=CACHE_DIR):
    """
    Export colors.json directly from the colors dictionary.
    This ignores all system and user template files.
    """
    # Create the output directory if it doesn't exist
    if not os.path.exists(output_dir):
        create_dir(output_dir)

    # 1. Generate the color image palette (colors.png)
    generate_color_images(colors, output_dir)

    # 2. Generate colors.json from nothing (the data object)
    json_path = os.path.join(output_dir, "colors.json")
    
    try:
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(colors, f, indent=4)
        
        logging.info("Successfully created colors.json at %s", json_path)
    except Exception as e:
        logging.error("Failed to create colors.json: %s", e)

    logging.info("Export finished. Template system bypassed.")


def color(colors, export_type, output_file=None):
    """
    Legacy export function. 
    Since templates are removed, this now only supports JSON export.
    """
    if export_type == "json":
        every(colors, os.path.dirname(output_file) if output_file else CACHE_DIR)
    else:
        logging.warning("Template exports are disabled. Only JSON is supported.")

def main():
    """Main script function."""
    setup_logging()

    parser = get_args()
    parse_args_exit(parser)
    parse_args(parser)


if __name__ == "__main__":
    main()
