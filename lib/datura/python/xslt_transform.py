#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path


def parse_args():
    # create the parser
    parser = argparse.ArgumentParser(description="XSLT transform using saxonche")
    # declare the arguments
    parser.add_argument("--input",  required=True,  help="Path to source XML file")
    parser.add_argument("--xsl",    required=True,  help="Path to XSL stylesheet")
    parser.add_argument("--output", required=False, help="Path to write output file")
    parser.add_argument("--param",  action="append", default=[], metavar="KEY=VALUE",
                        help="XSL parameter (repeatable)")
    # parse sys.argv, validate args, return namespace object with attributes
    return parser.parse_args()


def run_transform(input_path, xsl_path, params, output_path=None):
    # import here rather than at top so error is raised at call time with clear traceback if saxonche isn't installed
    import saxonche
    # create Saxon processor using Home Edition tier
    with saxonche.PySaxonProcessor(license=False) as proc:
        # create XSLT 3.0 processor
        xslt_proc = proc.new_xslt30_processor()
        # iterate list of kv strings
        for kv in params:
            if "=" not in kv:
                raise ValueError(f"Invalid param format (expected KEY=VALUE): {kv!r}")
            key, value = kv.split("=", 1)
            xslt_proc.set_parameter(key, proc.make_string_value(value))
        # parse and compile xsl file into executable
        executable = xslt_proc.compile_stylesheet(stylesheet_file=xsl_path)
        # run transformation and return output as string
        result = executable.transform_to_string(source_file=input_path)
        # return error or write output to disk
        if result is None:
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
        )
    except Exception as e:
        print(f"XSLT transformation error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()