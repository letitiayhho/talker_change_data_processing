
t = 0:p:300-p;
x = cos(2*pi*tx./(1:5)'/100);

tiledlayout(3,1)

nexttile
plot(tx,x,'.:')
title('Original')
ylim([-1.5 1.5])

p = 3;
q = 2;
y = resample(x, p, q);
nexttile
plot(t, y)
title('Upsampled')

p = 3;
q = 2;
z = resample(x, q, p);
nexttile
plot(t, z)
title('Downsampled')