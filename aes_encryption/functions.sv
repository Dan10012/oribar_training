import aes_model_pack::*; 
package functions_pack;

	function byte[16] main_round (byte[16] state_data, byte[16] round_key);
		return mix_columns(shift_rows(Sub_bytes(state_data)))? ^ round_key;
	endfunction : 

	function byte[16] final_round (byte[16] state_data, byte[16] round_key);
		return shift_rows(Sub_bytes(state_data)) ^ round_key;
	endfunction : 

	function byte[16] key_generator (byte key[16], int round_number);
		byte first_column [3:0]; 
		byte round_key [16]; 
		first_column[0] = key[15];
		first_column[1:3] = key[12:14]

		round_key[0:3] = sub_bytes_func(first_column) ^ key[0:3] ^ RCON(round_number);
		round_key[4:7] = round_key[0:3] ^ key[4:7];
		round_key[8:11] = round_key[4:7] ^ key[8:11];
		round_key[12:15] = round_key[8:11] ^ key[12:15];

		return round_key; 
endfunction :

endpackage

function byte[16] sub_bytes_func (byte[16] state_data);
		for (int i = 0; i < 16; i++) begin
			
		end
endfunction 

function byte[16] shift_rows_func (byte state_data[16]) ;
	byte data_out[0:15]; 
	data_out[0:3] = state_data[0:3];

	data_out[4] = state_data[7];  
	data_out[5:7] = state_data[4:6];

	data_out[8:9] = state_data[10:11]; 
	data_out[10:11] = state_data[8:9];

	data_out[12:14] = state_data[13:15];  
	data_out[15] = state_data[12];

	return data_out; 		
endfunction : 

function byte[16] mix_columns (byte [7:0] state_data[16]);
	byte column [3:0]; 
	for (int i = 0; i < 4; i++) begin
		column = data_in[3+4*i : 4*i];
		data_out[0 + 4*i] = mult_fun(column[1], column[0], column[2], column[3]); 
		data_out[1 + 4*i] = mult_fun(column[2], column[1], column[3], column[0]);
		data_out[2 + 4*i] = mult_fun(column[3], column[2], column[0], column[1]);
		data_out[3 + 4*i] = mult_fun(column[0], column[3], column[1], column[2]);
	end
	
endfunction :  

function byte mult_fun (bit[7:0] matrix_three, bit[7:0] matrix_two, bit[7:0] matrix_one_first, bit[7:0] matrix_one_second);
	return  matrix_three ^ mult_by_two(matrix_three) ^ 	mult_by_two(matrix_two)	^ matrix_one_first ^ matrix_one_second;
endfunction : 

function bit[7:0] mult_by_two (bit[7:0] byte_in);
	bit[7:0] byte_out; 
	byte_out [7:1] = byte_in [6:0]; 
	byte_out[0] = 0 ?

	if byte_in[7] = 1 begin 
		byte_out = byte_out XOR 00011011;
	end if; 
	return byte_out; 
endfunction : 