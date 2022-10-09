### Asynchronous clock domain crossings ###
set_false_path -through [get_pins -regexp SyncAsyncx/oSyncStages.*/(PRE|CLR)]
set_false_path -through [get_pins SyncAsyncx/oSyncStages_reg[0]/D]
set_false_path -through [get_pins -regexp ReRegister.iIn_q.*/(CLR|PRE)]