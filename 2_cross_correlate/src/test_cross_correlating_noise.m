iters = 2000;

extreme = zeros(1, iters);
for i = 1:iters
    a = normalize(rand(1, 16));
    b = normalize(rand(1, 16));
    r = xcorr(a, b);
    mn = min(r);
    mx = max(r);
    if mx > abs(mn)
        extreme(i) = mx;
    else
        extreme(i) = mn;
    end
end

average = mean(extreme);
histogram(extreme)
hold on;
line([average, average], ylim, 'LineWidth', 2, 'Color', 'r');