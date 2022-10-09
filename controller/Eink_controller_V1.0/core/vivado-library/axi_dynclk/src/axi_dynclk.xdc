### Asynchronous clock domain crossings ###
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages*/PRE || NAME =~ *SyncAsync*/oSyncStages*/CLR || NAME =~ *SyncAsync*/oSyncStages_reg[0]/D} -hier]
#set_false_path -through [get_pins -filter {NAME =~ */SyncBase*/iIn_q*/PRE || NAME =~ */SyncBase*/iIn_q*/CLR} -hier]

# The handshake module does not need recovery check on aReset
#set_false_path -through [get_pins HandshakeData*/*/CLR]