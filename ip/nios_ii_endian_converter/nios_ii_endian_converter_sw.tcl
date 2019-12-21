# Create a new driver - this name must be different than the 
# hardware component name
create_driver nios_ii_endian_converter_driver

# Associate it with some hardware known as "Nios II Endian Converter"
set_sw_property hw_class_name nios_ii_endian_converter

# The version of this driver is "1.0"
set_sw_property version 1.0
set_sw_property min_compatible_hw_version 1.0

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize false

# Location in generated BSP that sources will be copied into
set_sw_property bsp_subdirectory drivers

#
# Source file listings...
#

# Include files
add_sw_property include_source inc/endian_converter_macros.h

# This driver supports HAL type
add_sw_property supported_bsp_type HAL

# End of file
