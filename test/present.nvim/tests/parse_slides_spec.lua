local parse = require("present")._parse_slides

local eq = assert.are.same

describe("present.parse_slides", function()
    it("should parse an empty file", function()
        local expect = {
            {
                title = "",
                body = {},
                blocks = {},
            }
        }

        eq(expect, parse {})
    end)

    it("should parse a file with one slide", function()
        local expect = {
            {
                title = "# Title",
                body = { "Content" },
                blocks = {}
            }
        }

        local file = {
            "# Title",
            "Content"
        }

        eq(expect, parse(file))
    end)

    it("should parse a file with one slide, and a block", function()
        local result = parse({
            "# Title",
            "Content",
            "```lua",
            "print('Hello')",
            "print('world!')",
            "```",
        })

        eq(1, #result)

        local slide = result[1]

        eq("# Title", slide.title)

        eq({
            "Content",
            "```lua",
            "print('Hello')",
            "print('world!')",
            "```",
        }, slide.body)

        eq({
            lang = "lua",
            body = "print('Hello')\nprint('world!')",
        }, slide.blocks[1])
    end)
end)
