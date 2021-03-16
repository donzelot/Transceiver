%
%THIS IS A WIZARD GENERATED FILE. DO NOT EDIT THIS FILE!
%
%---------------------------------------------------------------------------------------------------------
%This is a filter with fixed coefficients.
%This Model Only Support Single Channel Input Data.
%Please input:
%data vector: 		stimulation(1:n)

%    This Model Only Support FIR_WIDTH to 51 Bits

%FILTER PARAMETER
%Input Data Width: 32
%Interpolation Factor: 1
%Decimation Factor: 2
%FIR Width (Full Calculation Width Before Output Width Adjust) :62
%-----------------------------------------------------------------------------------------------------------
%MegaWizard Scaled Coefficient Values

function  output = rx_ciccomp_mlab(stimulation, bank);
 coef_matrix_in= [-461,-2533,469,2760,-507,-3154,564,3721,-648,-4486,748,5453,-873,-6651,1010,8087,-1167,-9790,1330,11773,-1507,-14068,1683,16693,-1867,-19694,2036,23094,-2201,-26952,2339,31308,-2459,-36251,2531,41851,-2558,-48243,2498,55543,-2365,-64001,2083,73858,-1640,-85561,907,99644,188,-117072,-1932,139220,4654,-168684,-9385,209821,17904,-272265,-36047,378084,82929,-596135,-269551,1210913,2097151,1210913,-269551,-596135,82929,378084,-36047,-272265,17904,209821,-9385,-168684,4654,139220,-1932,-117072,188,99644,907,-85561,-1640,73858,2083,-64001,-2365,55543,2498,-48243,-2558,41851,2531,-36251,-2459,31308,2339,-26952,-2201,23094,2036,-19694,-1867,16693,1683,-14068,-1507,11773,1330,-9790,-1167,8087,1010,-6651,-873,5453,748,-4486,-648,3721,564,-3154,-507,2760,469,-2533,-461];
 INTER_FACTOR  = 1;
 DECI_FACTOR  =  2;
 MSB_RM  = 0;
 MSB_TYPE  = 0;
 LSB_RM  = 0;
 LSB_TYPE  = 1;
 FIR_WIDTH  = 62 + MSB_RM + LSB_RM;
 OUT_WIDTH  = 62 ;  %62
 DATA_WIDTH = 32;

  
 % check size of inputs. 
 DY = size(stimulation, 2);
 CY = size(coef_matrix_in, 2);
 if CY ~= DY * INTER_FACTOR
    fprintf('WARNING : coef_matrix size and input data size does not match\n');
 end 

 %fill coef_matrix to length of data with the latest coef set 
 if CY < DY * INTER_FACTOR
     coef_matrix = coef_matrix_in(bank + 1, :);
   end 
	  
 % check if input is integer 
       	int_sti=round(stimulation); 
	    T = (int_sti ~= stimulation); 
	    if (max(T)~=0) 
	        fprintf('WARNING : Integer Input Expected: Rounding Fractional Input to Nearest Integer...\n'); 
	    end 
	     
	    %Input overflow check 
        %set max/min for signed 
        maxdat = 2^(DATA_WIDTH-1)-1; 
        mindat = -maxdat-1; 

	    %Saturating Input Value 
	    a=find(int_sti>maxdat); 
	    b=find(int_sti<mindat); 
	    if (~isempty(a)|~isempty(b)) 
	 	    fprintf('WARNING : Input Amplitude Exceeds MAXIMUM/MINIMUM allowable values - saturating input values...\n'); 
	            lena = length (a); 
	            lenb = length (b); 
	            for i =1:lena 
	        	    fprintf('%d > %d \n', int_sti(a(i)), maxdat); 
			        int_sti(a(i)) = maxdat; 
		        end 
		    for i =1:lenb 
			    fprintf('%d < %d \n', int_sti(b(i)), mindat); 
			    int_sti(b(i)) = mindat; 
		    end 
	    end 
         
	    % Add interpolation 
   	    inter_sti = zeros(1, INTER_FACTOR * length(int_sti)); 
	    inter_sti(1:INTER_FACTOR:INTER_FACTOR * length(int_sti)) = int_sti; 
 
         
        for i = 1 : DY *INTER_FACTOR 
    	    coef_current = coef_matrix(i,:); 
            output_temp(i) = simp_adaptive (inter_sti, coef_current, i); 
        end 

	% Truncate output 
	len1 = length(output_temp); 
	 
	    switch  LSB_TYPE 
	    case 0 
	        %truncate 
            out_dec = bi_trunc_lsb(output_temp,LSB_RM,FIR_WIDTH); 
	    case 1 
	        %round 
            out_dec = bi_round(output_temp,LSB_RM, FIR_WIDTH); 
	    end 
         
 	    switch  MSB_TYPE 
	    case 0 
	        %truncate 
            out_dec = bi_trunc_msb(out_dec,MSB_RM,FIR_WIDTH-LSB_RM); 
	    case 1 
	        %round 
            out_dec = bi_satu(out_dec,MSB_RM, FIR_WIDTH-LSB_RM); 
	    end 
 	    
    	% choose decimation output in phase=DECI_FACTOR-1  
     	if(DECI_FACTOR == 1) 
     		output = out_dec; 
else
    output = out_dec(1:DECI_FACTOR:len1);
end

function[output, outindex] = simp_adaptive (int_sti, coef_current, data_index)

	%Simulation is the whole input sequence 
	%coef_current is the current coefficient set 
	%data_index gives the last data to use 
    % output is the sum of input and coef multiplication
	%outindex is the next data_index 
    
    coef_length = length(coef_current);
	data_length = length(int_sti); 
	 
	if (data_index > data_length) 
		fprintf('ERROR: DATA INDEX IS LARGER THAN DATA LENGTH!!!\n'); 
        return
	end 
    min_index = max(data_index - data_length, 1);
    max_index = min(data_index, coef_length);
	 
	outindex= data_index+1; 
    output = int_sti(data_index + 1 - (min_index:max_index)) * coef_current(min_index:max_index).';
 
function output = bi_round(data_in,LSB_RM,ORI_WIDTH)
	% LSB_RM is the bit to lose in LSB 
	% ORI_WIDTH is the original data width

	data = round (data_in / 2^LSB_RM);

	output = bi_satu(data,0,ORI_WIDTH - LSB_RM); 
	 
function output = bi_trunc_lsb(data_in,LSB_RM,ORI_WIDTH)
	% LSB_RM is the bit to lose in LSB 
	% ORI_WIDTH is the original data width 
	%2's complement system 
	output = bitshift((2^ORI_WIDTH*(data_in<0)) + (2^LSB_RM)*floor(data_in/(2^LSB_RM)), -LSB_RM) - (2^(ORI_WIDTH-LSB_RM)) *(data_in<0); 
	 
function output = bi_trunc_msb(data_in,MSB_RM,ORI_WIDTH)
	% MSB_RM is the bit to lose in LSB 
	% ORI_WIDTH is the original data width 
	%2's complement system 
	data = 2^ORI_WIDTH * (data_in < 0)+ data_in; 
	erase_num = 2^(ORI_WIDTH - MSB_RM) - 1; 
	data = bitand(data, erase_num); 
	output = data - 2^(ORI_WIDTH - MSB_RM)*(bitget(data,ORI_WIDTH - MSB_RM)); 
	 
function output = bi_satu(data_in,MSB_RM,ORI_WIDTH)
	% MSB_RM is the bit to lose in LSB 
	% ORI_WIDTH is the original data width 
	%2's complement system 
	maxdat = 2^(ORI_WIDTH - MSB_RM - 1)-1; 
	mindat = 2^(ORI_WIDTH - MSB_RM - 1)*(-1); 
    data_in(data_in > maxdat) = maxdat;
    data_in(data_in < mindat) = mindat;
	output = data_in; 

