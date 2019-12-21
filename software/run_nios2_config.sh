 #!/bin/bash

cd ../ ;
nios2-configure-sof phy_nios_2.sof;
sleep 3;
cd software/phy_nios_2.elf;
nios2-download -g phy_nios_2_sw.elf
