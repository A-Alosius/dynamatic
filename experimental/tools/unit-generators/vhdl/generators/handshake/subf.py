from generators.support.signal_manager import generate_buffered_signal_manager
from generators.handshake.join import generate_join
from generators.support.delay_buffer import generate_delay_buffer
from generators.handshake.buffers.one_slot_break_dv import generate_one_slot_break_dv


def generate_subf(name, params):
    is_double = params["is_double"]
    extra_signals = params["extra_signals"]

    if extra_signals:
        return _generate_subf_signal_manager(name, is_double, extra_signals)
    else:
        return _generate_subf(name, is_double)


def _generate_subf(name, is_double):
    if is_double:
        return _generate_subf_double_precision(name)
    else:
        return _generate_subf_single_precision(name)


def _get_latency(is_double):
    return 12 if is_double else 9  # todo


def _generate_subf_single_precision(name):
    join_name = f"{name}_join"
    one_slot_break_dv_name = f"{name}_one_slot_break_dv"
    buff_name = f"{name}_buff"

    dependencies = generate_join(join_name, {"size": 2}) + \
        generate_one_slot_break_dv(one_slot_break_dv_name, {"bitwidth": 0}) + \
        generate_delay_buffer(
        buff_name, {"slots": _get_latency(is_double=False) - 1})

    entity = f"""
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity of subf_single_precision
entity {name} is
  port (
    -- inputs
    clk : in std_logic;
    rst : in std_logic;
    lhs : in std_logic_vector(32 - 1 downto 0);
    lhs_valid : in std_logic;
    rhs : in std_logic_vector(32 - 1 downto 0);
    rhs_valid : in std_logic;
    result_ready : in std_logic;
    -- outputs
    result : out std_logic_vector(32 - 1 downto 0);
    result_valid : out std_logic;
    lhs_ready : out std_logic;
    rhs_ready : out std_logic
  );
end entity;
"""

    architecture = f"""
-- Architecture of subf_single_precision
architecture arch of {name} is
  signal join_valid : std_logic;
  signal buff_valid, one_slot_break_dv_valid, one_slot_break_dv_ready : std_logic;

  -- subf is the same as addf, but we flip the sign bit of rhs
  signal rhs_neg : std_logic_vector(32 - 1 downto 0);

  -- intermediate input signals for IEEE-754 to Flopoco-simple-float conversion
  signal ip_lhs, ip_rhs : std_logic_vector(32 + 1 downto 0);

  -- intermediate output signal for Flopoco-simple-float to IEEE-754 conversion
  signal ip_result : std_logic_vector(32 + 1 downto 0);
begin
  join_inputs : entity work.{join_name}(arch)
    port map(
      -- inputs
      ins_valid(0) => lhs_valid,
      ins_valid(1) => rhs_valid,
      outs_ready => one_slot_break_dv_ready,
      -- outputs
      outs_valid => join_valid,
      ins_ready(0) => lhs_ready,
      ins_ready(1) => rhs_ready
    );

  one_slot_break_dv : entity work.{one_slot_break_dv_name}(arch)
    port map(
      clk => clk,
      rst => rst,
      ins_valid => buff_valid,
      outs_ready => result_ready,
      outs_valid => result_valid,
      ins_ready => one_slot_break_dv_ready
    );

  rhs_neg <= not rhs(32 - 1) & rhs(32 - 2 downto 0);

  buff : entity work.{buff_name}(arch)
    port map(
      clk,
      rst,
      join_valid,
      one_slot_break_dv_ready,
      buff_valid
    );

  ieee2nfloat_0 : entity work.InputIEEE_32bit(arch)
    port map(
      X => lhs,
      R => ip_lhs
    );

  ieee2nfloat_1 : entity work.InputIEEE_32bit(arch)
    port map(
      X => rhs_neg,
      R => ip_rhs
    );

  nfloat2ieee : entity work.OutputIEEE_32bit(arch)
    port map(
      X => ip_result,
      R => result
    );

  operator : entity work.FloatingPointAdder(arch)
    port map(
      clk => clk,
      ce => one_slot_break_dv_ready,
      X => ip_lhs,
      Y => ip_rhs,
      R => ip_result
    );
end architecture;
"""

    return dependencies + entity + architecture


def _generate_subf_double_precision(name):
    join_name = f"{name}_join"
    one_slot_break_dv_name = f"{name}_one_slot_break_dv"
    buff_name = f"{name}_buff"

    dependencies = generate_join(join_name, {"size": 2}) + \
        generate_one_slot_break_dv(one_slot_break_dv_name, {"bitwidth": 1}) + \
        generate_delay_buffer(
        buff_name, {"slots": _get_latency(is_double=True) - 1})

    entity = f"""
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity of subf_double_precision
entity {name} is
  port (
    -- inputs
    clk : in std_logic;
    rst : in std_logic;
    lhs : in std_logic_vector(64 - 1 downto 0);
    lhs_valid : in std_logic;
    rhs : in std_logic_vector(64 - 1 downto 0);
    rhs_valid : in std_logic;
    result_ready : in std_logic;
    -- outputs
    result : out std_logic_vector(64 - 1 downto 0);
    result_valid : out std_logic;
    lhs_ready : out std_logic;
    rhs_ready : out std_logic
  );
end entity;
"""

    architecture = f"""
-- Architecture of subf_double_precision
architecture arch of {name} is
  signal join_valid : std_logic;
  signal buff_valid, one_slot_break_dv_valid, one_slot_break_dv_ready : std_logic;

  -- subf is the same as addf, but we flip the sign bit of rhs
  signal rhs_neg : std_logic_vector(64 - 1 downto 0);

  -- intermediate input signals for IEEE-754 to Flopoco-simple-float conversion
  signal ip_lhs, ip_rhs : std_logic_vector(64 + 1 downto 0);

  -- intermediate output signal for Flopoco-simple-float to IEEE-754 conversion
  signal ip_result : std_logic_vector(64 + 1 downto 0);
begin
  join_inputs : entity work.{join_name}(arch)
    port map(
      -- inputs
      ins_valid(0) => lhs_valid,
      ins_valid(1) => rhs_valid,
      outs_ready => one_slot_break_dv_ready,
      -- outputs
      outs_valid => join_valid,
      ins_ready(0) => lhs_ready,
      ins_ready(1) => rhs_ready
    );
  one_slot_break_dv : entity work.{one_slot_break_dv_name}(arch)
    port map(
      clk => clk,
      rst => rst,
      ins_valid => buff_valid,
      outs_ready => result_ready,
      outs_valid => result_valid,
      ins_ready => one_slot_break_dv_ready,
      ins(0) => '0',
      outs => open
    );

  rhs_neg <= not rhs(64 - 1) & rhs(64 - 2 downto 0);

  buff : entity work.{buff_name}(arch)
    port map(
      clk,
      rst,
      join_valid,
      one_slot_break_dv_ready,
      buff_valid
    );

  ieee2nfloat_0 : entity work.InputIEEE_64bit(arch)
    port map(
      X => lhs,
      R => ip_lhs
    );

  ieee2nfloat_1 : entity work.InputIEEE_64bit(arch)
    port map(
      X => rhs_neg,
      R => ip_rhs
    );

  nfloat2ieee : entity work.OutputIEEE_64bit(arch)
    port map(
      X => ip_result,
      R => result
    );

  operator : entity work.FPAdd_64bit(arch)
    port map(
      clk => clk,
      ce => one_slot_break_dv_ready,
      X => ip_lhs,
      Y => ip_rhs,
      R => ip_result
    );

end architecture;
"""

    return dependencies + entity + architecture


def _generate_subf_signal_manager(name, is_double, extra_signals):
    bitwidth = 64 if is_double else 32
    return generate_buffered_signal_manager(
        name,
        [{
            "name": "lhs",
            "bitwidth": bitwidth,
            "extra_signals": extra_signals
        }, {
            "name": "rhs",
            "bitwidth": bitwidth,
            "extra_signals": extra_signals
        }],
        [{
            "name": "result",
            "bitwidth": bitwidth,
            "extra_signals": extra_signals
        }],
        extra_signals,
        lambda name: _generate_subf(name, is_double),
        _get_latency(is_double))
