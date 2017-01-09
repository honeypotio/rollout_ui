module RolloutUi
  class Wrapper
    class NoRolloutInstance < StandardError; end

    attr_reader :rollout

    def initialize(rollout = nil)
      @rollout = rollout || RolloutUi.rollout
      raise NoRolloutInstance unless @rollout
    end

    def groups
      rollout.instance_variable_get("@groups").keys
    end

    def add_feature(feature)
      redis.sadd(:features, feature)
    end

    def features(search_str = nil)
      features = redis.get('feature:__features__').to_s.split(',')
      deleted_features = redis.smembers(:deleted_rollout_features)

      features.keep_if do |feature|
        next false if deleted_features.include?(feature)
        search_str.to_s == '' || feature.downcase =~ /#{search_str.downcase}/
      end

      features.sort
    end

    def redis
      rollout.instance_variable_get("@storage")
    end
  end
end
