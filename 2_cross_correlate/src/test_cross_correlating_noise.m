iters = 2000;

extreme = zeros(1, iters);
avg = zeros(1, iters);
for i = 1:iters
    a = normalize(rand(1, 16));
    b = normalize(rand(1, 16));
    r = xcorr(a, b);
    mn = min(r);
    mx = max(r);
    avg(i) = mean(r);
    if mx > abs(mn)
        extreme(i) = mx;
    else
        extreme(i) = mn;
    end
end

avg_avg = mean(avg); % basically 0
avg_max = mean(extreme); % bimodal centered around 0
histogram(extreme)
hold on;
line([average, average], ylim, 'LineWidth', 2, 'Color', 'r');