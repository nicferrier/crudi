[{"h1": "this is a title"},
 {"img": {"title": "this is an element with attributes and no body",
          "src": "https://www.gravatar.com/avatar/e94960f8e47c178e206a869c3b81165d"}},
 {"div": {"alt": "this is an element with attributes and a body",
          "_" : "this is just a text body. It's identified in the attribute list by a _. So any object with a _ is actually an attribute list."}},
 {"ul": [{"li": "this is a normal child element"},
         {"li": "and this is another"},
         {"li": {"class": "last",
                 "_": [{"div": "this is the last element."},
                       {"span": {"class": "highlight",
                                 "_": "It has highlighted parts."}},
                       {"div": "And other parts are not highlighted."}]}}]},
 {"p": ["this is a paragraph with a ",
        {"a": {"href": "http://google.com",
               "_": "link to google.com"}}
        "in it."]}]
