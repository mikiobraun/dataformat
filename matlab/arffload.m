function ARFF = arffload(filename)
% arffload - load an arff file
%
% SYNPOSIS
%    ARFF = arffload(FILENAME)
%
% RETURNS
%    ARFF struct with fields
%      .relation        - name of the relation
%      .attributes      - attribute names
%      .attribute_types - attribute types
%      .attribute_data  - attribute data
%      .data            - the actual data as cell-array
%      .comment         - the initial comment of the file
%      .size            - number of items
%      .warnings        - if exists, number of parse errors
%
% DESCRIPTION
%    arffloads loads an arff file and returns a structure
%    containing the data.
%

% AUTHOR
%    (c) 2008 by Mikio L. Braun, mikio@cs.tu-berlin.de

f = fopen(filename, 'r');

state = 'comment';

comment = {};
retry = 0;
lineno = 0;
warnings = 0;

C = struct();
C.attributes = {};
C.attribute_types = {};
C.attribute_data = {};

while ~feof(f)
  if retry
    retry = 0;
  else
    l = fgetl(f);
    lineno = lineno + 1;
  end
  
  %fprintf('%s: %s\n', state, l)
  
  switch state
   case 'comment' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(l) >= 1 && l(1) == '%'
      if length(l) >= 2
        if l(2) == ' '
          l = l(2:end);
        end
        comment = horzcat(comment,  l(2:end));
      else
        comment = horzcat(comment, '');
      end
    else
      state = 'header';
      C.comment = comment;
      retry = 1;
    end
   case 'header' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ll = lower(l);
    if startswith('@relation ', ll)
      W = split(l);
      C.relation = W{2};
    elseif startswith('@attribute ', ll)
      W = split(l);
      name = W{2};
      type = W{3};
      lowertype = lower(type);
      switch lowertype
       case 'real'
        addattribute(name, 'numeric', [])
       case 'integer'
        addattribute(name, 'numeric', [])
       case 'numeric'
        addattribute(name, 'numeric', [])
       case 'string'
        addattribute(name, 'string', [])
       otherwise
        % paste type definition together in case there was
        % a space in there
        if type(1) == '{'
          if type(end) ~= '}'
            J = 3;
            while J <= length(W) && type(1) == '{' && type(end) ~= '}'
              J = J + 1;
              type = horzcat(type, W{J});
            end
            if J > length(W);
              warning(['syntax error in nominal attribute definition: missing ' ...
                       'closing "}"'])
              break
            end
          end
          
          % check for nominal type definition
          if type(1) == '{' && type(end) == '}'
            values = type(2:end-1);
            values = splitby(values, ',');
            addattribute(W{2}, 'nominal', values);
          end
        else
          warning('cannot parse attribute definition')
        end
      end
    elseif startswith('@data', ll)
      state = 'data';

      % set up data array
      na = length(C.attributes);
      data = cell(1,na);
      for I = 1:na
        % fill in empty values
        switch C.attribute_types{I}
         case 'numeric'
          data{I} = [];
         case 'string'
          data{I} = {};
         case 'nominal'
          data{I} = {};
        end
      end
      
      items = 0;
    end
   case 'data' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(l) && l(1) ~= '%'
      tokens = splitby(l, ',');

      if length(tokens) ~= na
        warning(sprintf('wrong number of values (expected %d, got %d)', ...
                        na, length(tokens)));
        continue
      end
      
      items = items + 1;
      
      for I = 1:na
        value = tokens{I};
        switch C.attribute_types{I}
         case 'numeric'
          value = str2num(value);
          if isempty(value)
            warning('cannot parse numeric value')
            continue
          end
         case 'string'
          % everythings okay
         case 'nominal'
          ad = C.attribute_data{I};
          found = 0;
          for J = 1:length(ad)
            if strcmp(value, ad{J})
              found = 1;
            end
          end
          
          if ~found
            warning('illegal nominal value')
            continue
          end
        end
        data{I} = vertcat(data{I}, value);
      end
    end
  end
end

ARFF = C;
ARFF.data = data;
ARFF.size = items;
if warnings > 0
  ARFF.warnings = warnings;
end

fclose(f);

% check whether a string l starts with head
function flag = startswith(head, l)
if length(l) >= length(head)
  flag = strcmp(head, l(1:length(head)));
else
  flag = 0;
end
end

% Split a string by white-spaces
function W = split(S)
W = {};
while ~isempty(S)
  [T, S] = strtok(S);
  W = horzcat(W, T);
end
end

% Split a string by a delimiter, remove whitespaces.
function W = splitby(S, D)
I = 1;
W = {};
while ~isempty(S)
  J = strfind(S(2:end), D);
  if isempty(J)
    break
  end
  T = S(I:J);
  S = S(J+2:end);
  W = horzcat(W, trim(T));
end
T = trim(S);
if ~isempty(S)
  W = horzcat(W, T);
end

end

% Remove whitespaces from front and back.
function S = trim(S)
  while S(1) == ' '
    S = S(2:end)
  end
  while S(end) == ' '
    S = S(1:end-1)
  end
end

function addattribute(name, type, data)
C.attributes = horzcat(C.attributes, name);
C.attribute_types = horzcat(C.attribute_types, type);
C.attribute_data = horzcat(C.attribute_data, { data });
end

function warning(msg)
fprintf('warning line %d: %s\n', lineno, msg);
warnings = warnings + 1;
end

end % of arffload