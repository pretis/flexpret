'''
    The following sets gather instructions with similar cycle count execution
    pattern. The pattern is given in an array, where cycle_count(i) is the cycle
    count for the given frequency 1/(i+1), and 0 <= i <= 3.
    If the cycle count is fixed, then the value is given as an integer. If it is 
    not, then it X or 1. Such varying cycle count will be reoported as a string 
    of the X value.

    All remaining will follow one same cycle count that is 1, for all frequencies.
'''
# 'beqz is added  manually
branch_inst = {'beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu', 'beqz'}
# branch_inst_cc = ['3OR1',   '2OR1',   1,   1]
branch_inst_cc = ['3',   '2',   1,   1]

# FIXME: 'j' is to be verified 
jump_inst = {'jal', 'jalr', 'j'}
# jump_inst_cc = [3,   2,   1,   1]
jump_inst_cc = [3,   2,   1,   1]

load_inst = {'lb', 'lh', 'lw', 'lbu', 'lhu'}
# load_inst_cc = [2,   1,   1,   1]
load_inst_cc = [2,   1,   1,   1]

scall_inst = {'scall'}
# scall_inst_cc = [5,   2,   2,   1]
scall_inst_cc = [5,   2,   2,   1]

timing_inst = {'du', 'wu'}
# timing_inst_cc = ['5OR1',   '3OR1',   '2OR1',   '2OR1']
timing_inst_cc = ['5',   '3',   '2',   '2']

fence_i_inst = {'fence_i'}
# fence_i_inst_cc = [4,   2,   2,   1]
fence_i_inst_cc = [4,   2,   2,   1]

def get_cc (inst, f):
    '''
    Returns the cycle count of the given instruction, based on the frequency.
    The default vealue to return in 1. 
    '''
    if (inst in branch_inst):
        return branch_inst_cc[f-1]
    if (inst in jump_inst):
        return jump_inst_cc[f-1]
    if (inst in load_inst):
        return load_inst_cc[f-1]
    if (inst in scall_inst):
        return scall_inst_cc[f-1]
    if (inst in timing_inst):
        return timing_inst_cc[f-1]
    if (inst in fence_i_inst):
        return fence_i_inst_cc[f-1]
    return 1

# instruction_cycle_count = {
#     # menmonic f= 1/1  1/2  1/3  1/4
#     'lui':       [1,   1,   1,   1],
#     'auipc':     [1,   1,   1,   1],
#     'addi':      [1,   1,   1,   1],
#     'slli':      [1,   1,   1,   1],
#     'slti':      [1,   1,   1,   1],
#     'sltiu':     [1,   1,   1,   1],
#     'xori':      [1,   1,   1,   1],
#     'srli':      [1,   1,   1,   1],
#     'srai':      [1,   1,   1,   1],
#     'ori':       [1,   1,   1,   1],
#     'andi':      [1,   1,   1,   1],
#     'add':       [1,   1,   1,   1],
#     'sub':       [1,   1,   1,   1],
#     'sll':       [1,   1,   1,   1],
#     'slt':       [1,   1,   1,   1],
#     'sltu':      [1,   1,   1,   1],
#     'xor':       [1,   1,   1,   1],
#     'srl':       [1,   1,   1,   1],
#     'sra':       [1,   1,   1,   1],
#     'or':        [1,   1,   1,   1],
#     'and':       [1,   1,   1,   1],

#     'jalr':      [3,   2,   1,   1],
#     'jal':       [3,   2,   1,   1],

#     # Table 3.2
#     'beq':       ['3OR1',   '2OR1',   1,   1],
#     'bne':       ['3OR1',   '2OR1',   1,   1],
#     'blt':       ['3OR1',   '2OR1',   1,   1],
#     'bge':       ['3OR1',   '2OR1',   1,   1],
#     'bltu':      ['3OR1',   '2OR1',   1,   1],
#     'bgeu':      ['3OR1',   '2OR1',   1,   1],

#     # Table 3.3
#     'sb':        [1,   1,   1,   1],
#     'sh':        [1,   1,   1,   1],
#     'sw':        [1,   1,   1,   1],

#     'lb':        [2,   1,   1,   1],
#     'lh':        [2,   1,   1,   1],
#     'lw':        [2,   1,   1,   1],
#     'lbu':       [2,   1,   1,   1],
#     'lhu':       [2,   1,   1,   1],
#     # Table 3.4
#     'csrrw':     [1,   1,   1,   1],
#     'csrrs':     [1,   1,   1,   1],
#     'csrrc':     [1,   1,   1,   1],
#     'csrrwi':    [1,   1,   1,   1],
#     'csrrsi':    [1,   1,   1,   1],
#     'csrrci':    [1,   1,   1,   1],
#     # Table 3.5
#     'scall':     [5,   2,   2,   1],
#     'sret':      [1,   1,   1,   1],
#     # Table 3.7
#     'du':        ['5OR1',   '3OR1',   '2OR1',   '2OR1'],
#     'wu':        ['5OR1',   '3OR1',   '2OR1',   '2OR1'],
#     # Table 3.8
#     'ie':        [1,   1,   1,   1],
#     'ee':        [1,   1,   1,   1],    #?
#     # Table 3.9
#     'fence':     [1,   1,   1,   1],
#     'fence_i':   [4,   2,   2,   1],

#     'addiw':     [1,   1,   1,   1],
#     'slliw':     [1,   1,   1,   1],
#     'srliw':     [1,   1,   1,   1],
#     'sraiw':     [1,   1,   1,   1],
#     'addw':      [1,   1,   1,   1],
#     'subw':      [1,   1,   1,   1],
#     'sllw':      [1,   1,   1,   1],
#     'srlw':      [1,   1,   1,   1],
#     'sraw':      [1,   1,   1,   1],
#     'ld':        [1,   1,   1,   1],
#     'lwu':       [1,   1,   1,   1],
#     'sd':        [1,   1,   1,   1],
#     'mul':       [1,   1,   1,   1],
#     'mulh':      [1,   1,   1,   1],
#     'mulhsu':    [1,   1,   1,   1],
#     'mulhu':     [1,   1,   1,   1],
#     'div':       [1,   1,   1,   1],
#     'divu':      [1,   1,   1,   1],
#     'rem':       [1,   1,   1,   1],
#     'remu':      [1,   1,   1,   1],
#     'mulw':      [1,   1,   1,   1],
#     'divw':      [1,   1,   1,   1],
#     'divuw':     [1,   1,   1,   1],
#     'remw':      [1,   1,   1,   1],
#     'remuw':     [1,   1,   1,   1],
#     'amoadd_w':  [1,   1,   1,   1],
#     'amoxor_w':  [1,   1,   1,   1],
#     'amoor_w':   [1,   1,   1,   1],
#     'amoand_w':  [1,   1,   1,   1],
#     'amomin_w':  [1,   1,   1,   1],
#     'amomax_w':  [1,   1,   1,   1],
#     'amominu_w': [1,   1,   1,   1],
#     'amomaxu_w': [1,   1,   1,   1],
#     'amoswap_w': [1,   1,   1,   1],
#     'lr_w':      [1,   1,   1,   1],
#     'sc_w':      [1,   1,   1,   1],
#     'amoadd_d':  [1,   1,   1,   1],
#     'amoxor_d':  [1,   1,   1,   1],
#     'amoor_d':   [1,   1,   1,   1],
#     'amoand_d':  [1,   1,   1,   1],
#     'amomin_d':  [1,   1,   1,   1],
#     'amomax_d':  [1,   1,   1,   1],
#     'amominu_d': [1,   1,   1,   1],
#     'amomaxu_d': [1,   1,   1,   1],
#     'amoswap_d': [1,   1,   1,   1],
#     'lr_d':      [1,   1,   1,   1],
#     'sc_d':      [1,   1,   1,   1],
#     'sbreak':    [1,   1,   1,   1],
#     'fadd_s':    [1,   1,   1,   1],
#     'fsub_s':    [1,   1,   1,   1],
#     'fmul_s':    [1,   1,   1,   1],
#     'fdiv_s':    [1,   1,   1,   1],
#     'fsgnj_s':   [1,   1,   1,   1],
#     'fsgnjn_s':  [1,   1,   1,   1],
#     'fsgnjx_s':  [1,   1,   1,   1],
#     'fmin_s':    [1,   1,   1,   1],
#     'fmax_s':    [1,   1,   1,   1],
#     'fsqrt_s':   [1,   1,   1,   1],
#     'fadd_d':    [1,   1,   1,   1],
#     'fsub_d':    [1,   1,   1,   1],
#     'fmul_d':    [1,   1,   1,   1],
#     'fdiv_d':    [1,   1,   1,   1],
#     'fsgnj_d':   [1,   1,   1,   1],
#     'fsgnjn_d':  [1,   1,   1,   1],
#     'fsgnjx_d':  [1,   1,   1,   1],
#     'fmin_d':    [1,   1,   1,   1],
#     'fmax_d':    [1,   1,   1,   1],
#     'fcvt_s_d':  [1,   1,   1,   1],
#     'fcvt_d_s':  [1,   1,   1,   1],
#     'fsqrt_d':   [1,   1,   1,   1],
#     'fle_s':     [1,   1,   1,   1],
#     'flt_s':     [1,   1,   1,   1],
#     'feq_s':     [1,   1,   1,   1],
#     'fle_d':     [1,   1,   1,   1],
#     'flt_d':     [1,   1,   1,   1],
#     'feq_d':     [1,   1,   1,   1],
#     'fcvt_w_s':  [1,   1,   1,   1],
#     'fcvt_wu_s': [1,   1,   1,   1],
#     'fcvt_l_s':  [1,   1,   1,   1],
#     'fcvt_lu_s': [1,   1,   1,   1],
#     'fmv_x_s':   [1,   1,   1,   1],
#     'fclass_s':  [1,   1,   1,   1],
#     'fcvt_w_d':  [1,   1,   1,   1],
#     'fcvt_wu_d': [1,   1,   1,   1],
#     'fcvt_l_d':  [1,   1,   1,   1],
#     'fcvt_lu_d': [1,   1,   1,   1],
#     'fmv_x_d':   [1,   1,   1,   1],
#     'fclass_d':  [1,   1,   1,   1],
#     'fcvt_s_w':  [1,   1,   1,   1],
#     'fcvt_s_wu': [1,   1,   1,   1],
#     'fcvt_s_l':  [1,   1,   1,   1],
#     'fcvt_s_lu': [1,   1,   1,   1],
#     'fmv_s_x':   [1,   1,   1,   1],
#     'fcvt_d_w':  [1,   1,   1,   1],
#     'fcvt_d_wu': [1,   1,   1,   1],
#     'fcvt_d_l':  [1,   1,   1,   1],
#     'fcvt_d_lu': [1,   1,   1,   1],
#     'fmv_d_x':   [1,   1,   1,   1],
#     'flw':       [1,   1,   1,   1],
#     'fld':       [1,   1,   1,   1],
#     'fsw':       [1,   1,   1,   1],
#     'fsd':       [1,   1,   1,   1],
#     'fmadd_s':   [1,   1,   1,   1],
#     'fmsub_s':   [1,   1,   1,   1],
#     'fnmsub_s':  [1,   1,   1,   1],
#     'fnmadd_s':  [1,   1,   1,   1],
#     'fmadd_d':   [1,   1,   1,   1],
#     'fmsub_d':   [1,   1,   1,   1],
#     'fnmsub_d':  [1,   1,   1,   1],
#     'fnmadd_d':  [1,   1,   1,   1]
# }