#!/usr/bin/env python
"""This utility convert jupyter notebook into a python .py file"""

import argparse
import io
import re
from pathlib import Path

import pandas as pd
from IPython.core.interactiveshell import InteractiveShell
from nbformat import read


def fix_model_params(codes):
    """To replace the first cell (params) with a dict argument"""

    params_cell = codes.pop(0)

    new_cell = """
# Code block needed for nb_to_py.py and parallel_run.py
try:
    if isinstance(params, dict): # see if params is passed in from upper level
        is_params = True
    else:
        is_params = False
except NameError:
    is_params = False

"""
    # Get the param lines
    p = re.compile(r"^.*=.*$", re.MULTILINE)
    lines = p.findall(params_cell)
    lines_res = []
    for line in lines:
        if r"#" in line:
            line = line.split("#")[0]
        line = line.strip()
        lines_res.append(line)
    lines = lines_res
    # print("\n".join(lines))

    # Get the default values
    new_cell += "\n".join(lines)

    # Get the part for is_params:
    new_cell += "\nif is_params:\n"
    is_params_lines = []
    for line in lines:
        param = line.split("=")[0].strip()
        new_line = "    if '{param}' in params: {param} = params['{param}']".format(
            param=param
        )
        is_params_lines.append(new_line)
    new_cell += "\n".join(is_params_lines)

    codes.insert(0, new_cell)

    return codes


def fix_up_code(py_code, nb_filepath):
    """To fix up the converted code by addressing some formatting issues"""

    # Format the code so that it has a main()
    py_code = "    ".join(py_code.splitlines(True))

    block_top = '''"""
Model:       {nb_name}
Description: This is an automatically generated file by function nb_to_py.py (FincLab Library)

Warning - DO NOT MODIFY THIS FILE.

    >>>    Please modify in the original Jupyter Notebook:
    >>>        {nb_filepath}
    >>>    And then generate this file using nb_to_py.py

The source of the code is available in GitHub repo.
"""
from pathlib import Path
import pandas as pd
import numpy as np
import datetime
import warnings
import re
import logging
import itertools
import os
import argparse
import sys
import socket
import logging
import uuid
import nbformat
import copy
import multiprocessing
import shutil
import zipfile
import time


# Check if running in EQPY environment. Use 'master' as the default.
if not 'EQPY_ENV' in os.environ: os.environ['EQPY_ENV'] = 'master'
if not 'EQPY_PATH' in os.environ: os.environ['EQPY_PATH'] = str(Path(Path.home(), 'att', 'master').absolute())
if not 'EQPY_SRC_PATH' in os.environ: os.environ['EQPY_SRC_PATH'] = str(Path(Path.home(), 'att', 'master', 'src').absolute())
folder_project = Path(os.environ['EQPY_PATH'])
start_datetime = pd.Timestamp.now()


def _main(params=None):
    '''.format(
        nb_name=nb_filepath.stem, nb_filepath=str(nb_filepath.absolute())
    )

    block_bottom = '''
def main(params=None):
    try:
        print("launching module {nb_name}...")
        _main(params=params)
        print("Execution of module {nb_name} completed sucessfully...")
    except Exception as e:
        from eq.att.core.engine import AttEngine
        import os, sys
        import os.path
        att = AttEngine(env=os.environ['EQPY_ENV'],
          init_kdb_connections=False,
          log_level='info')

        att.logger.error("Execution of {nb_name} encountered an error.")

        exc_type, exc_obj, exc_tb = sys.exc_info()
        fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
        f = exc_tb.tb_frame
        filename = f.f_code.co_filename
        import linecache
        import traceback
        linecache.checkcache(filename)
        line = linecache.getline(filename, exc_tb.tb_lineno, f.f_globals)

        str_traceback = traceback.format_exc()
        lst_traceback = []
        import re
        import pandas
        import datetime
        str_traceback  = "<br>".join(re.findall(r'^.*$', str_traceback, re.MULTILINE))
        valid_types_to_display = [bool, int, str, pandas._libs.tslibs.timestamps.Timestamp, datetime.datetime]

        # Figure out params
        str_params = ""
        if params is not None:
            for param, val in params.items():
                if type(param) in valid_types_to_display:
                    str_params += str(param) + ": "
                else:
                    continue
                if type(val) in valid_types_to_display:
                    str_params += str(val) + ","
                else:
                    str_params += "non-string, "

        # distribute an email notification
        subject = f'[ATT Robot] [Module: {nb_name}] FAILED'
        import getpass
        import socket
        box_username = getpass.getuser()
        box_hostname = socket.gethostname()
        content = "<p>Execution has failed for the below module on host " + box_hostname + "(" + box_username + "):</p>" + \
        "<p><strong>    {nb_filepath_parent}/" + str(fname) + "</strong></p>" + \
        """
        <p></p>
        <p>Please see the below for error specifics.</p>
        <p></p>
        """ + \
        "<p>Input parameters:</p>" + \
        "<p>" + str_params + "</p>" + \
        "<p><strong>Error Command:</strong> " + str(line.strip()) + "</p>" + \
        "<p><strong>Line Number:</strong> " + str(exc_tb.tb_lineno) + "</p>" + \
        """<p><span style="color: #ff0000;"><strong>Error message:</strong></span></p>""" + \
        "<p>" + str(exc_type) + "</p>" + \
        "<p>" + str(e) + "</p>" + \
        """<p><span style="color: #ff0000;"><strong>Trace Back:</strong></span></p>""" + \
        "<p>    " + str(str_traceback) + "</p>"


        print(traceback.format_exc())
        att.email.send(send_from='info@finclab.com',
        send_to=['peter.lee@finclab.com'], subject=subject, content=content)
        print("Execution of {nb_name} encountered an error. An email has been sent.")


if __name__=='__main__':
    main()
    print("Execution of {nb_name} is completed.")
    '''.format(
        nb_name=nb_filepath.stem,
        nb_filepath=str(nb_filepath.absolute()),
        nb_filepath_parent=str(nb_filepath.parent.absolute()),
    )
    py_code = "\n".join([block_top, py_code, block_bottom])

    # To remove magic ipython commands
    lines = py_code.splitlines(True)
    lines = ["" if "get_ipython" in line else line for line in lines]
    py_code = "".join(lines)

    # replace display as print
    py_code = py_code.replace("display(", "print(")
    py_code = py_code.replace("Markdown(", "print(")
    py_code = py_code.replace("md(", "print(")

    # replace raise to return
    py_code = py_code.replace("exit()", "return")
    py_code = py_code.replace("raise", "return")

    # Place a few lines of code to the top of the script
    place_to_top = []
    place_to_top.append("from __future__ import (absolute_import, division)")
    place_to_top.append("from __future__ import (print_function, unicode_literals)")
    place_to_top.append("import pandas as pd")
    place_to_top.append("import numpy as np")
    for line in place_to_top:
        py_code = py_code.replace(line, "")
    place_to_top.append(py_code)
    py_code = "\n".join(place_to_top)

    return py_code


def export_notebook_to_python(nb_filepath, py_filepath=None):
    """Convert a jupyter notebook to a python .py file

    Args:
        nb_filepath (Path): the jupyter notebook filepath
        py_filepath (Path): the target .py filepath
    """
    nb_filepath = Path(nb_filepath)

    # Figure out the output python filename
    if py_filepath is None:
        py_filepath = Path(nb_filepath.parent, nb_filepath.stem + ".py")
    else:
        py_filepath = Path(py_filepath)

    with io.open(nb_filepath, "r", encoding="utf-8") as filename:
        nb = read(filename, 4)

    codes = []
    for cell in nb.cells:
        if cell.cell_type == "code":

            # Transform any ipython magics to proper Python codes
            shell = InteractiveShell.instance()
            code = shell.input_transformer_manager.transform_cell(cell.source)

            codes.append(code)

    codes = fix_model_params(codes)

    py_code = "\n".join(codes)

    py_code = fix_up_code(py_code, nb_filepath)

    py_filepath.write_text(py_code, encoding="utf-8")


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description="Convert the target Notebook into a Python .py file"
    )

    parser.add_argument(
        "-n",
        "--nb_filepath",
        help="Specify the full/relative path of the target Notebook file",
        required=True,
        action="store",
    )

    parser.add_argument(
        "-p",
        "--py_filepath",
        help="Specify the full/relative path of the output Python .py file",
        required=False,
        action="store",
    )

    args = vars(parser.parse_args())

    export_notebook_to_python(
        nb_filepath=args["nb_filepath"], py_filepath=args["py_filepath"]
    )
