# Lyric Bot

Given a corpus of lyrics (eg, all the lyrics to Hamilton) in a text file, this bot will detect partial lyrics in public tweets and post the next few lines.

Specifically, if the last few words of a tweet match the last few words of a line from the corpus, it's considered a match.

## Setup

Run the bot with `ruby bot.rb`

You'll need to provide some configuration as environment variables.  You can provide these a few ways:

- On the command line: `CONSUMER_KEY=abc123 CONSUMER_SECRET=def789 [...] ruby bot.rb`
- Via a .env file (see .sample.env in this repo)
- As environment variables in your hosting environment.  Eg if you're using heroku, `heroku config:set CONSUMER_KEY=abc123` will set the environment variable such that the bot can access it.

### The variables
```
CONSUMER_KEY=abc123
CONSUMER_SECRET=def789
ACCESS_TOKEN=ghi101
ACCESS_SECRET=jkl112
MATCH_SCORE_THRESHOLD=14
SEND_TWEETS=true
```

The keys/secrets/tokens are from your twitter app.  If you're not familiar with
those, you'll need to do some reading in the twitter api guide.

The `MATCH_SCORE_THRESHOLD` variable determines how sensitive the lyric detection is.  Higher numbers will require more words to match, resulting in better but less-frequent matches. Lower numbers will require fewer words to match, resulting in more, worse matches.  See "Matching logic" below for details.  14 seems to work pretty well for Hamilton (yielding around 1 match every couple hours).  You may need to adjust this for your specific corpus, though.

`SEND_TWEETS` is used for testing.  If set to `true`, tweets are actually sent.  Otherwise they're just logged to stdout.

## Matching logic
The exact number of words needed to trigger a match vary: words are weighted by how common they are ("the" and "me" are weighted much lower than "weighted" and "subjective").  Words are worth 2 to 9 points.  A candidate tweet and a candidate lyric line need to have enough matching words such that the sum of the weighted score of those words exceeds a specific (configurable) threshold.

## TODOs
- Handle song-boundaries.  Right now, someone tweeting the last line of a song might get replied to with the first lines of the next song.
- Handle replies to the bot.  Right now we only look for matches in the public feed.  We should also look for matches in replies (and reply back with new lyrics).  This'll let people sing hamilton along with the bot.  :)
- Generally clean up code.  It was a Sunday afternoon hack project.
