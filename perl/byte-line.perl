eu procurei a linha pelo perl 
perl -E '$off=shift;while(<>){​$sum+=length;if($sum>=$off){​say $.;exit}​}​' num_byte file_name