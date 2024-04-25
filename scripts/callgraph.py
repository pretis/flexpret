import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('top', help='Top level function to highlight from')

args = parser.parse_args()

LIGHT_BLUE = "blue"
ALL_CALLED = list()
TOP_FUNCTION = args.top

with open('callgraph/expands.txt', 'r') as f:
    callgraph = f.readlines()

def from_line_to_function_name(line):
    return re.findall('"([^"]*)"', line)[0]

def find_all_called_by_fuction(raw_callgraph, function):
    for line in raw_callgraph:
        if not '->' in line:
            continue
        lhs, rhs = line.split('->')
        lhs_function = from_line_to_function_name(lhs)
        rhs_function = from_line_to_function_name(rhs)
        if function == lhs_function and rhs_function not in ALL_CALLED:
            ALL_CALLED.append(rhs_function)
            find_all_called_by_fuction(raw_callgraph, rhs_function)

find_all_called_by_fuction(callgraph, TOP_FUNCTION)

callgraph.remove('}\n')
callgraph.append("\"" + TOP_FUNCTION + "\" [color=" + LIGHT_BLUE + ", style=filled];\n")
for call in ALL_CALLED:
    callgraph.append("\"" + call + "\" [color=" + LIGHT_BLUE + "];\n")
callgraph.append('}\n')

with open('callgraph/expands.txt.modified', 'w') as f:
    f.writelines(callgraph)
