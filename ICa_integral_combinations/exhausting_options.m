% this script moves through all possible combinations of
% integral controllers (Ca and iCa)

available_channels = {'ACurrent','CaS','CaT','HCurrent','KCa','Kd','NaV'};

i = 1;
j = 1;

while j < 8
  while(i < 8)
    dual_control(available_channels(j:i)) %sets j:i channels as iCa-current controlled
    i = i+1;
  end;
  j=j+1;
  i=j
end;
