local Print_RateLimitTracking = {}
function PrintRateLimited(text)
    if(Print_RateLimitTracking[text] == nil)then
        Print_RateLimitTracking[text] = _now
        print(text)
    elseif(Print_RateLimitTracking[text] + 10 < _now)then
        Print_RateLimitTracking[text] = _now
        print(text)
    else
        --skip
    end
end
