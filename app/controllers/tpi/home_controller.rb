module TPI
  class HomeController < TPIController
    # rubocop:disable Metrics/MethodLength
    def index
      @testimonials = [{
        'author' => 'Lee Van Cleef',
        'role' => 'Golden Boot Award Winner',
        'avatar_url' => ActionController::Base.helpers.asset_path('lee_van_cleef.jpg'),
        'message' => [
          'Oh I almost forgot. He gave me a thousand. I think his idea was that I kill you.',
          "But you know the pity is when I'm paid, I always follow my job through. You know that."
        ]
      }, {
        'author' => 'Eli Wallach as Tuco',
        'role' => 'Academy Award Honorary Winner',
        'avatar_url' => ActionController::Base.helpers.asset_path('eli_wallach.jpg'),
        'message' => [
          'I... I must tell you the truth, Blondie. In my place, you would do the same thing. ' \
            "It's all over for you now. There's nothing anyone can do any more.",
          "Oh, God, forgive me! It's my fault!"
        ]
      }, {
        'author' => 'Clint Eastwood as Blondie',
        'role' => 'Four-time Academy Award Winner',
        'avatar_url' => ActionController::Base.helpers.asset_path('clint_eastwood.jpg'),
        'message' => [
          'You see in this world there are two kinds of people my friend. ' \
            'Those with loaded guns, and those who dig. You dig.'
        ]
      }]
    end
    # rubocop:enable Metrics/MethodLength

    def about; end

    def sandbox; end

    def newsletter; end
  end
end
