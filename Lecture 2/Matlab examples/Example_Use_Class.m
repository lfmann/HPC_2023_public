clear all
clc

% We initialize an object
h(1) = household(12,2008,4,4,62450,58300);

% We initialize an empty object
h(2) = household();

% TODO: my test

% We fill in part of an empty object
h(2).consumption = 14576;
h(2).size = 2;

% We show the default property
h.year

% We operate on the object
c(1) = equivalenceScale(h(1));

[m,n] = size(h);

% We compute average consumption by looping
averageConsumption = 0;
for i = 1:n
    averageConsumption = averageConsumption+h(i).consumption;
end
m1 = averageConsumption/2

% We do the same using the predefined method
m2 = averageconsumption(h(1),h(2))

% Using an overloaded operator
h(1)+h(2)
