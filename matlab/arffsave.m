function arffsave(ARFF, filename)
% arffsave - save an arff structure to a file
%
% SYNPOSIS
%     success = arffsave(ARFF)

% AUTHOR
%    Mikio L. Braun, mikio@cs.tu-berlin.de
% see below for copyright information


% do some checks on the structure to make sure we're actually
% dealing with an ARFF structure... .
ARFF_FIELDS = { 'attributes', 'attribute_types', ...
                'attribute_data', 'data', 'relation', 'size' };

if ~isstruct(ARFF) || ~all(isfield(ARFF, ARFF_FIELDS))
  error('You must pass a structure. See the documentation');
end

na = length(ARFF.attributes);
if length(ARFF.attribute_types) ~= na
  error('field attribute_types must have the same length as the field attributes')
end
if length(ARFF.attribute_data) ~= na
  error('field attribute_data must have the same length as the field attributes')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write initial comment
f = fopen(filename, 'w');

if isfield(ARFF, 'comment')
  comment = ARFF.comment;
  for I = 1:length(comment)
    fprintf(f, '%% %s\n', comment{I});
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write relation definition
fprintf(f, '@relation %s\n', ARFF.relation);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write attribute definitions
for I = 1:na
  fprintf(f, '@attribute %s ', ARFF.attributes{I});
  switch ARFF.attribute_types{I}
   case 'numeric'
    fprintf(f, 'numeric');
   case 'string'
    fprintf(f, 'string');
   case 'nominal'
    ad = ARFF.attribute_data{I};
    fprintf(f, '{%s', ad{1});
    for J = 2:length(ad)
      fprintf(f, ',%s', ad{J});
    end
    fprintf(f, '}');
   otherwise
    error(sprintf('Unknown attribute type %s', ARFF.attribute_types{I}))
  end
  fprintf(f, '\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write data
fprintf(f, '@data\n');

for I = 1:ARFF.size
  print_datum(ARFF, 1, 1);
  for J = 2:na
    fprintf(f, ',');
    print_datum(ARFF, I, J);    
  end
  fprintf(f, '\n');
end

fclose(f);


function print_datum(ARFF, I, J)
values = ARFF.data{J};
switch ARFF.attribute_types{J}
 case 'numeric'
  fprintf(f, '%f', values(I));
 case 'string'
  fprintf(f, '%s', values{I});
 case 'nominal'
  fprintf(f, '%s', values{I});
end
end

end

% Copyright (c) 2008, Mikio L. Braun, Cheng Soon Ong, Soeren Sonnenburg
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
% notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above
% copyright notice, this list of conditions and the following disclaimer
% in the documentation and/or other materials provided with the
% distribution.
%     * Neither the names of the Technical University of Berlin, ETH
% Zürich, or Fraunhofer FIRST nor the names of its contributors may be
% used to endorse or promote products derived from this software without
% specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
% A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
% OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
% THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
