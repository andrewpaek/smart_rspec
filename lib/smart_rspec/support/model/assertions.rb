module SmartRspec
  module Support
    module Model
      module Assertions
        def validates_email_of(attr, validation)
          it 'has an invalid format' do
            %w(foobar foobar@ @foobar foo@bar).each do |e|
              be_valid_expectation(attr, e, subject.dup)
            end
          end
        end

        def validates_exclusion_of(attr, validation)
          it 'has a reserved value' do
            be_valid_expectation(attr, validation[:in].sample)
          end
        end

        def validates_format_of(attr, validation)
          it 'does not match the required format' do
            mock, with =
              validation.values_at(:mock).first,
              validation.values_at(:with).first

            if mock && with && with !~ mock
              be_valid_expectation(attr, mock)
            else
              raise ArgumentError, ':with and :mock are required when using the :format validation'
            end
          end
        end

        def validates_inclusion_of(attr, validation)
          it 'is out of the scope of possible values' do
            begin
              value = SecureRandom.hex
            end while validation[:in].include?(value)
            be_valid_expectation(attr, value)
          end
        end

        def validates_length_of(attr, validation)
          validation.each do |key, value|
            next unless [:in, :is, :maximum, :minimum, :within].include?(key)
            txt, n = build_length_validation(key, value)
            it txt do
              be_valid_expectation(attr, 'x' * n)
            end
          end
        end

        def validates_presence_of(attr, validation)
          it 'is blank' do
            be_valid_expectation(attr, nil, subject.dup)
          end
        end

        def validates_uniqueness_of(attr, validation)
          it 'is already in use' do
            if !validation.is_a?(Hash) || !validation.has_key?(:mock)
              raise ArgumentError, 'A "mock" must be set when validating the uniqueness of a record'
            elsif subject.persisted? || subject.save
              mock, scope = validation.values_at(:mock, :scope)
              mock.send("#{scope}=", subject.send(scope)) unless scope.to_s.empty?
              be_valid_expectation(attr, subject.send(attr), mock)
            end
          end
        end

        def assert_has_attributes(attrs, options) type_str = build_type_str(options)
          attrs.each do |attr|
            it %Q(has an attribute named "#{attr}"#{type_str}) do
              expect(subject).to respond_to(attr)
              has_attributes_expectation(attr, options)
            end
          end
        end

        def assert_association(type, associations)
          associations.each do |model|
            it "#{type.to_s.gsub('_', ' ')} #{model}" do
              expect(subject).to respond_to(model)
              association_expectation(type, model)
            end
          end
        end

        def build_length_validation(key, value)
          case key
          when :in, :within then ['is out of the length range', value.max + 1]
          when :is, :minimum then ["is #{key == :is ? 'invalid' : 'too short'}", value - 1]
          when :maximum then ['is too long', value + 1]
          end
        end

        def build_type_str(options)
          if !options.nil? && options[:type]
            " (%s%s%s)" % [
              ('Enumerated ' if options[:enum]),
              options[:type],
              (", default: #{options[:default]}" if options[:default])
            ]
          end
        end

        # def scoped_validation?(validation)
        #   validation.is_a?(Hash) && ([:scope, :mock] - validation.keys).empty?
        # end
      end
    end
  end
end
