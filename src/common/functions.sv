function automatic logic [num-1:0] repeat_value(input logic input_value, input int num);
    logic [num-1:0] tmp_v;
begin
    tmp_v = {num{input_value}}; // Powielamy wartość `input_value` `num` razy
    return tmp_v;
end
endfunction
