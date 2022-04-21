function Smooth = my_conv_circ(S1, sig)

S1 = [S1 S1];

NN = size(S1,1);
NT = size(S1,2);

dt = -4*sig:1:4*sig;
gaus = exp( - dt.^2/(2*sig^2));
gaus = gaus'/sum(gaus);

% Norms = conv(ones(NT,1), gaus, 'same');
%Smooth = zeros(NN, NT);
%for n = 1:NN
%    Smooth(n,:) = (conv(S1(n,:)', gaus, 'same')./Norms)';
%end

Smooth = filter(gaus, 1, [S1' ones(NT,1); zeros(4*sig, NN+1)]);
Smooth = Smooth(1+4*sig:end, :);
Smooth = Smooth(:,1:NN) ./ (Smooth(:, NN+1) * ones(1,NN));

Smooth = Smooth';

Smooth = Smooth(:, [NT/2+ [1:NT/4] NT/4+ [1:NT/4]]);