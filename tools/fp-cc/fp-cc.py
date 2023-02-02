'''
    This tool computes the number of cycles in a tagged piece of FlexPRET assembly
    code (provided as argument). Currently, the tagged piece should not include 
    a function call.
    
    The tool takes into account the scheduling frequency (provided as argument),
    and outputs a formula.

    TODO: (immediate) Add support for:
    - Function call
    - Build a specific compiler for FelxPRET
    - Interrupts in general, and interrupt_on_expire in particular
    - Try to find out the number of iterations

    @author: Chadlia Jerad
'''

import argparse
import re
import networkx as nx
import matplotlib.pyplot as plt
import inst_cc as ficc
from os.path import exists

# Set the argumenst list
parser = argparse.ArgumentParser(description='Prediction of the number of cycles.')
# Default of the file to process is just temporary to ease testing
parser.add_argument('-fn','--filename', type=str, default= 'test_programs/test.dump',
                    help='Name and path of the dump file.')
parser.add_argument('-l','--label', type=str, default='',
                    help='Label inserted to tag the region.')
parser.add_argument('-f','--frequency', type=int, default=4,
                    choices = [1, 2, 3, 4, 5, 6, 7, 8],
                    help='Scheduling frequency.')

dump_file = ''
asm_graph = nx.DiGraph()

# Regular expression, to check if the line in the dump file contains assembly code
# An example or such pattern is: '    1a9c:	 fcc42703          	lw	a4,-52(s0)'
reg_exp = '^[\s]{4}[0-9a-f\s]{3}[0-9a-f]{1}:[\s]{1,4}[0-9a-f]{8}[\s]{8}(\w|\W)*$'


class nbr_cycle_formula():
    '''
    Class modeling the formula with the number of cycles, with three main parts:
    - A constant, coming from adding constant cycles of instructions.
    - An array of loops. Each loop is itself a formula, and has its constant value
      associated to it.
    - An array of if else conditions. The condition is itself a formula as well,
      and has its constant value associated to it.
    - An array of time delays
    '''

    def __init__(self, cnst_init):
        self.cnst = cnst_init
        self.ifelse_cnst = []
        self.ifelse = []
        self.loop = []
        self.loop_cnst = []
        self.timedelay = []
        
    def add_ifelse (self, ifelse_nbr_cycle_formula, cnst):
        self.ifelse.append(ifelse_nbr_cycle_formula)
        self.ifelse_cnst.append(cnst)

    def add_loop (self,loop_nbr_cycle_formula, cnst):
        self.loop.append(loop_nbr_cycle_formula)
        self.loop_cnst.append(cnst)

    def add_timedelay (self, timedelay_nbr_cycle_formula):
        self.timedelay.append(timedelay_nbr_cycle_formula)

    def add_formula(self, formula_nbr_cycle_formula) :
        self.cnst = self.cnst + formula_nbr_cycle_formula.cnst
        self.ifelse.extend(formula_nbr_cycle_formula.ifelse)
        self.ifelse_cnst.extend(formula_nbr_cycle_formula.ifelse_cnst)
        self.loop.extend(formula_nbr_cycle_formula.loop)
        self.loop_cnst.extend(formula_nbr_cycle_formula.loop_cnst)
        self.timedelay.extend(formula_nbr_cycle_formula.timedelay)


    def print_formula(self) :
        '''
        Constructs the string out of a formula.

        Args: None
        Returns: A human readable string with the formula.
        '''
        prediction = str(self.cnst)

        if (self.ifelse):
            prediction += ' + ['
            for idx, formula in enumerate(self.ifelse):
                prediction += str(self.ifelse_cnst[idx])
                prediction += ' OR (' + formula.print_formula() + ') + '
            prediction = prediction[:-3] + ']'

        if (self.loop):
            prediction += ' + ['
            for idx, formula in enumerate(self.loop):
                prediction += '(' + str(self.loop_cnst[idx])
                prediction += ' + N x (' + formula.print_formula()
                prediction += ')) + '
            prediction = prediction[:-3] + ']'

        if (self.timedelay):
            prediction += ' + ['
            for formula in self.timedelay:
                prediction += '(1 OR (' + str(formula) + ' + delta'
                prediction += ')) + '
            prediction = prediction[:-3] + ']'
        
        return (prediction)


def process_assembly_line(line, frequency) :
    '''
    If the line does not include a comment from the original code, then use 
    a regular expression to extract the address, the instruction, and possibly 
    the jump address. Then the node and its outgoing edges are added.
    The cycle count of the instruction is added to the node. 

    Args: 
    - line: the line string from the dump file
    - frequency: int, the scheduling frequency, as it affects the cycle count
    Returns: string with the node (the address), if an instruction was extracted,
      and an empty string otherwise. 
    '''
    pattern = re.compile(reg_exp)
    if (bool(pattern.search(line))) :
        # Get the address and the instruction and keep the address in the hexadecimal 
        # format (0x...), so that it is easier to compute values
        address = line[4:8]
        src_node = str(hex(int(address, 16)))
        instruction = (line[29:-1]).split()[0]

        # Add it the asm_graph, set the intruction and the type
        asm_graph.add_node(src_node)
        asm_graph.nodes[src_node]['inst'] = instruction
        asm_graph.nodes[src_node]['cc'] = ficc.get_cc(instruction, frequency)

        # Compute the address of the next address anyway
        sink_node_4 = str(hex(int(address, 16) + 4)) #src+4

        # Here, we need to distinguish the graph buiding If it is a branch or jump instruction, then get the address given at the end
        if ((instruction in ficc.branch_inst) or (instruction in ficc.jump_inst)) :
            # Get the sink address
            jmp_address = ((line[29:-1]).split()[1]).split(',')
            jmp_address = jmp_address[len(jmp_address)-1]

            # Add the edge (of the jump)
            sink_node_jump = str(hex(int(jmp_address, 16))) # int(jmp_address, 16)
            asm_graph.add_edge(src_node, sink_node_jump, weight=3)
            if (instruction in ficc.branch_inst) :
                # In his case, the edge to the +4 node should be added as well
                asm_graph.add_edge(src_node, sink_node_4, weight=2)
        else :
            asm_graph.add_edge(src_node, sink_node_4, weight=1)
        return src_node
    return ''


def cycle_count(graph, node, graph_nbr_cycle) :
    '''
    A recursive function that parses a given graph to count the number of cycles.
    Loops, if conditions and timing conditions are processed differently.
    
    Args:
    - graph: a directed graph, where the cycle count will be performed
    - node: starting node
    - graph_nbr_cycle: formula to which the number of cycles will be added
    Returns: a formula of the number of cycles of the graph
    '''

    # Get the successor nodes
    successor_nodes = list(graph.successors(node))

    # This is the stop condition
    # If the end of the graph is reached, then return the 'zero' graph_nbr_cycle
    # Here we do not count the cc of the last added node 
    if (not successor_nodes):
        return(nbr_cycle_formula(0)) # FIXME: Should it really be 0? Yes!

    # Get the cycle count from the main asm_graph
    node_cc = asm_graph.nodes[node]['cc']
    node_inst = asm_graph.nodes[node]['inst']

    # Now, depending on the instruction type (branch, tining, other), check what to do.
    # The graph traversal will continue with the recursive call in all cases.

    #
    # Case where it is neither a branch nor a timing instruction
    # In this case, the cc is fixed and node_cc is an int
    #
    if ((node_inst not in ficc.branch_inst) and (node_inst not in ficc.timing_inst)) :
        # print('********************* '+node+' -- '+node_inst+' ** '+successor_nodes[0])
        # Here, len(successor_nodes) == 1 and type(node_cc) == int
        graph_nbr_cycle.cnst = graph_nbr_cycle.cnst + node_cc
        # Move
        graph_nbr_cycle.add_formula(cycle_count(graph, successor_nodes[0], nbr_cycle_formula(0)))
        return graph_nbr_cycle
    
    #
    # Case where it is a branch instruction, which boils to an if or a loop.
    # In this case, the cc is not fixed and node_cc is either an int or an str.
    # If it is an str, then it means that it is X OR 1
    #
    if (node_inst in ficc.branch_inst) :
        # If the branch results from an if statement, then both successors addresses
        # will have higher address than node
        if_node = False
        node_4 = str(hex(int(node, 16) + 4))
        node_jmp = ''
        for nd in successor_nodes:
            if (nd != node_4):
                node_jmp = nd
                break 

        if (int(nd,16) > (int(node_4, 16))):
            if_node = True

        node_cc = int(node_cc)
        # Case of an If:
        if (if_node):
            # Extract the subgraph of the non-met condition 
            sub_graph = build_sub_graph(graph, node_4, node_jmp)
     
            # Count the cycles of the subgraph
            subgraph_nbr_cycle = cycle_count(sub_graph, node_4, nbr_cycle_formula(0))
            # When the 
            subgraph_nbr_cycle.cnst += 1
            graph_nbr_cycle.add_ifelse(subgraph_nbr_cycle, node_cc)
            # Then continue and return
            graph_nbr_cycle.add_formula(cycle_count(graph, node_jmp, nbr_cycle_formula(0)))
            return graph_nbr_cycle
        else: # Case of a loop:
            # Extract the subgraph of the loop
            sub_graph = build_sub_graph(graph, node_jmp, node)
            # Count the cycles of the subgraph
            subgraph_nbr_cycle = cycle_count(sub_graph, node_jmp, nbr_cycle_formula(0))
            subgraph_nbr_cycle.cnst += node_cc
            graph_nbr_cycle.add_loop(subgraph_nbr_cycle, 1)
            # The continue and return
            graph_nbr_cycle.add_formula(cycle_count(graph, node_4, nbr_cycle_formula(0)))
            return graph_nbr_cycle

    #
    # Case where it is a timing instruction (du or wu).
    # In this case, the cc is not fixed. The cycle count of such instruction is
    # 1 OR cc(f).If the thread is put to sleep then we add 'delta' in the formula.
    #
    graph_nbr_cycle.add_timedelay(node_cc)
    # Move
    graph_nbr_cycle.add_formula(cycle_count(graph, successor_nodes[0], nbr_cycle_formula(0)))
    return graph_nbr_cycle


def build_sub_graph(graph, node_src, node_snk):
    '''
    Extracts the subgraph of all connected nodes going from node_src to node_snk.
    This is done by combining all possible paths connecting both nodes.

    Args:
    - graph: a directed graph
    - node_src: source node of the subgraph to construct
    - node_snk: sink node of the subgraph to construct
    Returns: the constructed subgraph (it is a directed graph)
    '''

    sub_graph = nx.DiGraph()
    sub_graph.add_node(node_src)

    # Iterate over all simple paths
    for path in nx.all_simple_paths(graph, source=node_src, target=node_snk):
        sub_graph.add_nodes_from(path)
        
        previous_nd = ''
        for nd in path:
            if (previous_nd != ''):
                sub_graph.add_edge(previous_nd, nd)
                # Unfortuneley, some paths are not detected by all_simple_paths()
                # Therefore, this is manual fix
                previous_nd_succ = list(graph.successors(previous_nd))

                if (len(previous_nd_succ) == 2):
                    other_nd = previous_nd_succ[0]
                    if (other_nd == nd):
                        other_nd = previous_nd_succ[1]
                    sub_graph.add_edge(previous_nd, other_nd)
                    for other_path in nx.all_simple_paths(graph, source=other_nd, target=node_snk):
                        sub_graph.add_nodes_from(other_path)
                        previous_previous_nd = ''
                        for nd2 in other_path:
                            if (previous_previous_nd != ''):
                                sub_graph.add_edge(previous_previous_nd, nd2)
                            previous_previous_nd = nd2

            previous_nd = nd
    # draw_asm_graph(sub_graph)
    return sub_graph


def process_dump_file(begin_label, end_label, frequency) :
    '''
    This is the main entry point of the program. Its behavior is described as a 
    simple state machine that searches the labels in the file and computes 
    the number of cycles.

    Args:
    - begin_label: string with the begin label
    - end_label: string with the end label
    - frequency: int of the scheduling frequency
    Returns: None
    '''
    global start_node
    line_number = 0
    line = dump_file.readline()
    start_node = ''
    state = 'search_begin'

    # Loop over the lines until the end comment is reached.
    while (line):
        line_number += 1

        # First, start by searching the begin comment line number
        if (state == 'search_begin') :
            if line.find(begin_label) >= 0:
                print ('Begin label foun at line: ' + str(line_number))
                state = 'extract_assembly'
            # else, stay at the same state and continue seraching for the begin comment

        elif (state == 'extract_assembly') :
            if line.find(end_label) >= 0:
                print ('End label foun at line: ' + str(line_number))
                state = 'cycle_count'
            else :
                nd = process_assembly_line(line, frequency)
                if (not start_node):
                    start_node = nd

        elif (state == 'cycle_count') :
            nbr_cycle = nbr_cycle_formula(0)
            cycle_count(asm_graph, start_node, nbr_cycle)
            print('******* Cycle Count Formula *******')
            print(nbr_cycle.print_formula())
            # We are done at this level
            break

        # Read the next line
        line = dump_file.readline()


def draw_asm_graph(graph):
    '''
    Draws the graph extracted from the assembly code.
    Args:
    - graph: A directed graph to draw
    Returns: None
    '''

    elarge = [(u, v) for (u, v) in graph.edges()]
    # Positions for all nodes - seed for reproducibility
    pos = nx.spring_layout(graph, seed=10)  
    # nodes
    nx.draw_networkx_nodes(graph, pos, node_size=700)      
    # edges
    nx.draw_networkx_edges(graph, pos, edgelist=elarge, width=6)
    # node labels
    nx.draw_networkx_labels(graph, pos, font_size=20, font_family='sans-serif')
    # edge type labels
    # edge_labels = nx.get_node_attributes(graph, 'weight')
    # nx.draw_networkx_edge_labels(graph, pos, edge_labels)     
    ax = plt.gca()
    ax.margins(0.08)
    plt.axis('off')
    plt.tight_layout()
    plt.show()

    
if __name__ == '__main__':
    args = parser.parse_args()

    # Check if the file exists
    # dump_file = open('../programs/mt-benchmarks/predictability/pr.dump', 'r')
    if (not exists(args.filename)):
        print('Fatal error: No such a file:' + args.filename + '! Aborting...')
        exit(0)

    dump_file = open(args.filename, 'r')

    begin_label = '// @BEGIN CYCLE COUNT: '
    begin_label += args.label
    end_label = '// @END CYCLE COUNT: '
    end_label += args.label 

    # Frequency
    frequency = args.frequency
    if (frequency > 4):
        frequency = 4
    
    process_dump_file(begin_label, end_label, frequency)
    
    draw_asm_graph(asm_graph)
    