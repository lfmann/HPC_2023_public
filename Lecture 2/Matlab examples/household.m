classdef household
    
    % Class to store information from a household from survery data
    
    properties
        id;
        year = 2005; % We specify a default value;
        quarter;
        size;
        income;
        consumption;
    end
    
    methods
        
        % class constructor
        function obj = household(id,year,quarter,size,income,consumption)  
            if(nargin > 0)
                obj.id = id;
                obj.year = year;
                obj.quarter = quarter;
                obj.size = size;
                obj.income = income;
                obj.consumption = consumption;
            end
        end
        
        % a function in the class
        function consumptionEquivalent = equivalenceScale(obj)
            if (obj.size==1)
                consumptionEquivalent = obj.consumption;
            else
                consumptionEquivalent = obj.consumption/(1+0.5*(obj.size-1));
            end
        end
        
        % a function with two objects
        function average = averageconsumption(obj1,obj2)
            average = 0.5*(obj1.consumption+obj2.consumption);
        end
        
        % overloading an operator
        function sum = plus(obj1,obj2)
            sum = obj1.consumption+obj2.consumption;
        end
        
    end
    
end
