# Makefile fragment for generating emulator using Chisel-testers.
# Currently intended for only single testbench and Chisel source project.
#
# Edward Wang <edwardw@eecs.berkeley.edu>

#------------------------------------------------------------------------------
# Generate emulator
#------------------------------------------------------------------------------

# Build a JAR file that runs CoreTesterMain as the main class.
# See build.scala for the details about this.
$(SBT_DIR)/Emulator/target/scala-2.11/Emulator-assembly-1.0.jar: $(SRC_DIR)/$(MODULE)/*.scala
	cd $(SBT_DIR) && \
	$(SBT) "project Emulator" "assembly"

$(EMULATOR_JAR): $(SBT_DIR)/Emulator/target/scala-2.11/Emulator-assembly-1.0.jar
	cp $(SBT_DIR)/Emulator/target/scala-2.11/Emulator-assembly-1.0.jar $(EMULATOR_JAR)
