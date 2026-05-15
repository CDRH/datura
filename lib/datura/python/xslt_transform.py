#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path

try:
    import saxonche
# this should now be redundant with the addition of check_xslt_dependency to data_manager.rb
# but I am leaving it here for now as a backstop and in case we decide to return to this approach 
# (the downside is that it will print an error for every call)
except ImportError as e:
    print(f"XSLT transformation error: {e}", file=sys.stderr)
    sys.exit(1)

def parse_args():
    # create the parser
    parser = argparse.ArgumentParser(description="XSLT transform using saxonche")
    # declare the arguments
    parser.add_argument("--input",  required=True,  help="Path to source XML file")
    parser.add_argument("--xsl",    required=True,  help="Path to XSL stylesheet")
    parser.add_argument("--output", required=False, help="Path to write output file")
    parser.add_argument("--param",  action="append", default=[], nargs=2, metavar=("KEY", "VALUE"),
                        help="XSL parameter as separate key and value (repeatable)")
    parser.add_argument("--base-output-uri", required=False, dest="base_output_uri",
                        help="Base URI for xsl:result-document secondary outputs (file:// URI or directory path)")
    # parse sys.argv, validate args, return namespace object with attributes
    return parser.parse_args()


def run_transform(input_path, xsl_path, params, output_path=None, base_output_uri=None):
    # create Saxon processor using Home Edition tier
    with saxonche.PySaxonProcessor(license=False) as proc:
        # create XSLT 3.0 processor
        xslt_proc = proc.new_xslt30_processor()
        # iterate list of [key, value] pairs
        for key, value in params:
            xslt_proc.set_parameter(key, proc.make_string_value(value))
        # parse and compile xsl file into executable
        executable = xslt_proc.compile_stylesheet(stylesheet_file=xsl_path)
        # set base output URI for xsl:result-document secondary outputs if provided;
        # convert plain directory path to file:// URI if needed
        if base_output_uri:
            if not base_output_uri.startswith("file://"):
                base_output_uri = Path(base_output_uri).resolve().as_uri() + "/"
            executable.set_base_output_uri(base_output_uri)
        # run transformation and return output as string
        result = executable.transform_to_string(source_file=input_path)
        # when a base output URI is set, None primary output is expected — all output
        # went to xsl:result-document secondary files; only error when neither was produced
        if result is None:
            if base_output_uri:
                return    
            raise RuntimeError("Transformation produced no output")
        if output_path:
            Path(output_path).write_text(result, encoding="utf-8")
        print(result, end="")


def main():
    args = parse_args()
    # catch exceptions
    try:
        run_transform(
            input_path=args.input,
            xsl_path=args.xsl,
            params=args.param,
            output_path=args.output,
            base_output_uri=args.base_output_uri,
        )
    except Exception as e:
        print(f"XSLT transformation error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()