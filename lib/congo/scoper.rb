module Congo
  module Scoper #:nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_congo_scoper
        if !self.included_modules.include?(MongoMapper::Document)
          class_eval <<-EOV

            include Congo::Scoper::InstanceMethods

            def scoper_instance
              @proxy_scoper ||= Congo::ProxyScoper.find_by_ext_id_and_ext_type(self.id, self.class.name)
              if @proxy_scoper.nil?
                @proxy_scoper = Congo::ProxyScoper.create!(:ext_type => self.class.name, :ext_id => self.id)                
              end
              @proxy_scoper
            end

            def content_types
              scoper_instance.content_types
            end
          EOV
        else
          class_eval <<-EOV
          
            include Congo::Scoper::InstanceMethods
            
            many :content_types, :class_name => 'Congo::ContentType', :as => :scope
            
            def scoper_instance
              nil
            end
          EOV
        end
      end
    end
    
    module InstanceMethods
      
      def proxy_scoper?
        !scoper_instance.nil?
      end
      
      def consts
        @consts ||= {}
      end
            
      def content_type_as_const(name, method_name = nil)
        return name.constantize if Object.const_defined?(name)
        
        unless consts[name]
          if (type = content_types.find_by_name(name)).nil?
            type = content_types.find_by_slug(method_name) if method_name
          end
          consts[name] = type.to_const rescue nil # This doesn't work because of different instances being used
        end
        
        consts[name]
      end
      
      private
      
      def method_missing(method, *args)
        if ctype = content_type_as_const(method.to_s.classify, method.to_s)
          meta = proxy_scoper? ? scoper_instance.metaclass : metaclass
          meta.many method, :class => ctype
          (proxy_scoper? ? scoper_instance : self).send(method, *args)
        else
          super
        end
      end
      
    end
  end
end

Object.class_eval { include Congo::Scoper }