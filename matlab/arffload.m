function ARFF = arffload(filename)
% arffload - load an arff file
%
% SYNPOSIS
%    ARFF = arffload(FILENAME)
%
% RETURNS
%    ARFF struct with fields
%    .attributes - attribute names
%    .attribute_types - attribute types
%    .attribute_data - attribute data
%    .data - the actual data as cell-array
%    .comment - the initial comment of the file
%
% DESCRIPTION
%    arffloads loads an arff file and returns a structure
%    containing the data.

f = fopen(filename, 'r');

state = 'comment';

comment = char();
retry = 0;

while ~feof(f)
  if retry
    retry = 0;
  else
    l = fgetl(f);
  end
  
  fprintf('%s: %s\n', state, l)
  
  switch state
   case 'comment'
    if length(l) > 1 && l(1) == '%'
      if length(l) > 2
        comment = [ comment, '\n', l(2:end) ];
      else
        comment = [ comment, '\n' ];
      end
    else
      state = 'header';
      retry = 1;
    end
   case 'header'
    ll = lower(l);
    if startswith('@relation ', ll)
      fprintf('relation!')
    elseif startswith('@attribute ', ll)
      fprintf('attribute!')
    elseif startswith('@data', ll)
      state = 'data'
    end
   case 'data'
  end
end

fclose(f);

function flag = startswith(head, l)
if length(l) > length(head)
  flag = strcmp(head, l(1:length(head)));
else
  flag = 0;
end