class Var < ActiveRecord::Base
    belongs_to :job
    belongs_to :action
    belongs_to :step
end
