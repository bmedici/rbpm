class Var < ActiveRecord::Base
    belongs_to :run
    belongs_to :action
    belongs_to :step
end
