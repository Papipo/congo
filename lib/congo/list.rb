module Congo
  module List
    
    def self.included(model)
      model.class_eval do
        include InstanceMethods
        
        def to_const_with_list
          klass = to_const_without_list
          apply_list(klass)
          klass
        end
        
        alias_method_chain :to_const, :list
      end
    end
    
    module InstanceMethods
            
      private
      
      def apply_list(klass)
        klass.key :_position, Integer, :default => 0
        
        klass.class_eval do
        
          include Congo::List::ContentInstanceMethods
        
          before_destroy :remove_from_list
          before_create  :add_to_list_bottom
          
          def self.reorder_all(ids)
            return false if ids.nil? or ids.empty?
            updates = {}
            ids.each_with_index do |id, index|
              updates[id] = { :_position => index + 1 }
            end
            self.update(updates)
          end
        end
      end

    end
    
    module ContentInstanceMethods
      
      private
      
      def add_to_list_bottom
        self._position = self.class.count + 1
      end
      
      def remove_from_list
        updates = {}        
        self.class.all(:conditions => { :_position.gt => self._position.to_i }).each do |item|
          updates[item._id] = { :_position => item._position - 1 }
        end
        self.class.update(updates) unless updates.empty?
      end
      
    end
    
  end
end