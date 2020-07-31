function [iz, unfeas, D] = bghungar(C);
%BGHUNGAR "Hungarian algorithm" to solve the square assignment problem
%
%#       For:
%#        C - a square profit/cost matrix.
%  [iz, unfeas, D] = bghungar(C);
%#       Returns:
%#       iz - the optimal assignment: MAXIMIZES total profit
%#        D - the square matrix equivalent to C at the end of iteration [1]
%
%  Note: For assignments that MINIMIZE cost just call BGHUNGAR, inverting
%        the sign of the cost matrix
%         [iz, unfeas, D] = bghungar(-C);



unfeas = 0;

%#(1)
[m,n] = size(C);

[r,ii] = max(C,[],1); C1 = ones(m,1)*r - C;

[c,jj] = min(C1,[],2); D = C1 - c*ones(1,n);

iz = zeros(m,1);
if any(isnan(D)), unfeas = 1; return; end

for j = 1:m
   kk = find( ~D(:,j) );
   while ~isempty(kk),
      i=kk(1); if ~iz(i), iz(i) = j; break; else, kk(1) = []; end
   end
end %j

izPrev = zeros(1,m);
%# --------------------------------------------

%#(2)
keepSets = 0;

%# occupied rows:
ii = find( iz );
while length( ii ) < m


if ~keepSets
   keepSets = 0;

%# ============================================
%# Reset the free sets:

   %# all rows & columns:
   rr = 1:m; cc = 1:n;

   %# --------------------------------------------

   %#(3)

   %# occupied columns:
   zz = iz(ii);

   %# free rows & columns:
   %% rr( ii ) = [];
   cc( zz ) = [];

%# ============================================

end %if ~keepSets

%# --------------------------------------------

while 1

   if any(isnan(D)), unfeas = 2; break; end

%#(4,5)
%# Find a row containing free zeros:

jz = 0;
for i = rr
   kk = find( ~D(i,cc) );
   if ~isempty(kk), jz = i; kz = cc(kk(1)); break; end
end %i

%# --------------------------------------------

if jz
%# Found a row containing free zeros:

   if iz(jz)
%#(6)
%# This row already has an assigned zero:
      kz = iz(jz); cc = [cc,kz]; zz(zz==kz) = []; rr(rr==jz) = [];

   else

%#(7)
%# This row has no assigned zero yet:
%#"Chain": Find a way to assign a zero to it:

% if size( izPrev, 1 ) == 3, disp('Start debugging: dbstep'); keyboard; end
      jz0 = jz; kz0 = kz; 
      iz0 = iz;

      while 1

%# in a column:
         iz(jz) = kz;
         rr1 = [1:jz-1, jz+1:m]; next = find( iz(rr1) == kz );
         if isempty(next), break; end
         jz = rr1(next(1));

%# in a row:
         iz(jz) = 0;
         cc1 = [1:kz-1, kz+1:n]; next = find( ~D(jz,cc1) );
         if isempty(next), break; end
         kz = cc1(next(1));

      end
%# go out of the infinite while-loop %#(5) here.
%# Detect alternating chains:
      if any( ismember( iz', izPrev,  'rows') )
         unfeas = 3; % break;

% kz0, iz', izPrev, iz0', disp(': dbcont'); keyboard
% jz0, kz0, rr, cc, E=D; E(logical(D))=1, disp(': dbstep'); keyboard

%# Block the free row/col (jz0,kz0) where all this started;



         iz = iz0;
         zz = [zz;kz0]; cc(cc==kz0) = []; %% rr(rr==jz0) = [];
% rr, cc

      else
        izPrev = [ izPrev; iz' ];
      end
      break;
   end

%# --------------------------------------------
else
%# No row containing free zeros found:
%# Create free zeros:

%#(8)
   p = min( min( D(rr,cc) ) );
   if p >= Inf, unfeas = 4; break; end
   D(rr,:) = D(rr,:) - p;
   D(:,zz) = D(:,zz) + p;

end% if jz

%# --------------------------------------------
end %while %#(5)

if unfeas==3,
   unfeas = 0; keepSets = 1;
else
   keepSets = 0;
end

if unfeas, break; end

ii = find( iz );

%# ============================================
end %while %#(2)


%# ============================================
% C, iz', izPrev, E=D; E(logical(D))=1, disp('Final: dbstep'); keyboard
% keepSets = 0;