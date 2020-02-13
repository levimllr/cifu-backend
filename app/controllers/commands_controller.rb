class CommandsController < ApplicationController
  def create

    sheet_link = "https://docs.google.com/spreadsheets/d/1FNN6pRAMpxZPdT4reFGSqo_2EPYo6W-X9wLFmuWbWYU/edit?usp=sharing"

    if params["command"] == "/bulletin"
      channel_id = params["channel_id"]
      command = params["text"].split(" ").first
      option = params["text"].split(" ").second

      case command
      when "intro"
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":u55b6: Hello world!\n:id: This channel's ID is *#{channel_id}*.\n:hash:To set up your mass message schedule, make a copy of this Google sheet:\n#{sheet_link}"
        )
      when "channel"
        channel_name = params["channel_name"]
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":id: #{channel_name}'s channel ID is *#{channel_id}*."
        )
      when "sheet"
        channel_name = params["channel_name"]
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":hash: To set up your mass message schedule, make a copy of this Google sheet:\n#{sheet_link}"
        )
      when "schedule"
        channel_name = params["channel_name"]
  
        messages = scheduled_messages(channel_id)

        if messages.length > 0

          schedule_string_prefix = [
            ":u6307: There are *#{messages.length} messages* scheduled for channel *#{channel_id}*.",
            ":u6708: Messages are scheduled between *#{format_unix_to_normal_time(messages.first.post_at)}* and *#{format_unix_to_normal_time(messages.last.post_at)}*:",
            "```",
            " # |    Local date, time    | Message ID",
            "---|------------------------|-----------"
          ]

          schedule_string = messages.map.with_index do |msg, idx| 
            " #{idx + 1} | #{Time.at(msg.post_at).strftime("%Y-%m-%d %I:%M:%S %p")} | #{msg.id}"
          end

          full_schedule_string = schedule_string_prefix.push(schedule_string).push("```").join("\n")

        else

          full_schedule_string = ":u6307: There are *_no_ messages* scheduled for channel *#{channel_id}*."

        end

        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: full_schedule_string
        )
      when "delete"
        case option
        when "all"
          message_ids = scheduled_messages(channel_id).map{|msg| msg.id}
          begin
            message_ids.each do |msg_id|
              delete_message(msg_id, channel_id)
            end
          rescue => exception
            bot_slack_client.chat_postMessage(
              channel: channel_id,
              text: ":u6e80: There's been an error deleting all messages!"
            )
          else
            bot_slack_client.chat_postMessage(
              channel: channel_id,
              text: ":congratulations: *All #{message_ids.length} schedules messages were successfully deleted!*"
            )
          end
        when nil
          bot_slack_client.chat_postMessage(
            channel: channel_id,
            text: ":u7981: To delete messages, enter either `/bulletin delete all` or `/bulletin delete MESSAGE_ID`."
          )
        else
          begin
            delete_message(option, channel_id)
          rescue => exception
            bot_slack_client.chat_postMessage(
              channel: channel_id,
              text: ":u6e80: No message with the id *#{option}* found!"
            )

          else
            bot_slack_client.chat_postMessage(
              channel: channel_id,
              text: ":u7a7a: The message with the id *#{option}* was successfully deleted!"
            )
          end
        end
      else
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":sos: Invalid command! Type `/bulletin` or click on my icon see options." 
        )
      end 
    end
  end

  private

  def scheduled_messages(channel_id)
    bot_slack_client.chat_scheduledMessages_list(
      channel: channel_id,
    )[:scheduled_messages].sort_by{ |msg| msg.post_at }
  end

  def delete_message(msg_id, channel_id)
    bot_slack_client.chat_deleteScheduledMessage(
      channel: channel_id,
      scheduled_message_id: msg_id
    )
  end
end
