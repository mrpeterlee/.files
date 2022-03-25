""" Install SpaceVim and update SymLinks

id:            Peter Lee (peter.lee@finclab.com)
last_update:   {Datetime}
type:          lib
sensitivity:   datalab@finclab.com
platform:      any
description:   This utilities contains the main steps to have SpaceVim Symlinks
properly setup.

It should work all Linux / Mac OS.
"""

import shutil
from pathlib import Path
import os.path
import finclab.io.file

DIR_SPACEVIM_USER_DATA = Path(Path.home(), ".SpaceVim.d")
DIR_SPACEVIM_SYSTEM = Path(Path.home(), ".SpaceVim")
DIR_DOTFILES = Path(Path.home(), ".files")

# SYMLINKS
symlinks = {
    # SpaceVim user folder
    DIR_SPACEVIM_USER_DATA:
    Path(DIR_DOTFILES, 'neovim', '.SpaceVim.d'),
    # pylintrc
    Path(Path.home(), '.pylintrc'):
    Path(DIR_DOTFILES, 'neovim', '.pylintrc'),
    # pydocstyle
    Path(Path.home(), '.config', 'pycodestyle'):
    Path(DIR_DOTFILES, 'neovim', 'pycodestyle'),
}


def main():
    """"""

    # Ensure the data folders exist
    if not Path(DIR_SPACEVIM_SYSTEM).is_dir():
        raise ValueError("@todo Install SPACEVIM for the 1st time.")

    for nonexist, exist in symlinks.items():
        print(f"Creating symlink from {exist} to {nonexist}...")
        finclab.io.file.update_symlink(nonexist, exist)


if __name__ == "__main__":
    main()
    print("Done...")
