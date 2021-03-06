require "htmlformatter"

describe HtmlFormatter do
  it "ignores HTML fragments in embedded EEX" do
    source = code <<-END
      <div>
        <%= Module.func("\n","<br />\n") %>
      </div>
    END
    expected = code <<-END
      <div>
        <%= Module.func("\n","<br />\n") %>
      </div>
    END
    expect(described_class.format(source, {engine: "eex"})).to eq(expected)
  end

  it "does not break line on embedded code within <script> opening tag" do
    source = %{<script src="<%= path %>" type="text/javascript"></script>}
    expect(described_class.format(source, {engine: "eex"})).to eq(source)
  end

  it "does not break line on embedded code within normal element" do
    source = %{<img src="<%= path %>" alt="foo" />}
    expect(described_class.format(source, {engine: "eex"})).to eq(source)
  end

  it "outdents else" do
    source = code <<-END
      <%= if @x do %>
      Foo
      <% else %>
      Bar
      <% end %>
    END
    expected = code <<-END
      <%= if @x do %>
        Foo
      <% else %>
        Bar
      <% end %>
    END
    expect(described_class.format(source, {engine: "eex"})).to eq(expected)
  end

  it "keeps multiline indentations" do
    source = code <<-END
      <div><div>
      <%= select f, :sort_by, [
            {"Account Created Date", :account_created_date},
            {"Last Name", :last_name},
            {"Email", :email},
          ] %>
      </div></div>
    END
    expected = code <<-END
      <div>
        <div>
          <%= select f, :sort_by, [
            {"Account Created Date", :account_created_date},
            {"Last Name", :last_name},
            {"Email", :email},
          ] %>
        </div>
      </div>
    END
    expect(described_class.format(source, {engine: "eex"})).to eq(expected)
  end

  it "has no trouble with complicated html" do
    source = code <<-END
      <x <% x %>>
        <% x %><% x %><% x %><% x %><% x %><% x %>
        <% x %><% x %><% x %><% x %><% x %><% x %>
        <% x %><% x %><% x %><% x %><% x %><% x %>
        <% x %><% x %><% x %><% x %><% x %><% x %>
      </x>
    END

    expected = code <<-END
      <x <% x %>>
        <% x %><% x %><% x %><% x %><% x %><% x %>
        <% x %><% x %><% x %><% x %><% x %><% x %>
        <% x %><% x %><% x %><% x %><% x %><% x %>
        <% x %><% x %><% x %><% x %><% x %><% x %>
      </x>
    END

    # this is very slow:
    # regex = %r{<\w+([^>]|<%.*?%>)*/>}om
    # puts regex.match(source.to_s)

    starting = Time.now
    expect(described_class.format(source, {engine: "eex"})).to eq(expected)
    ending = Time.now

    expect(ending - starting).to be < 1
  end

  it "indents special form_for in Phoenix LiveView" do
    source = code <<-END
      <%= f = form_for :form, "", [] %>
      <input type="text"/>
      </form>
      <%= f    =   form_for :form, "", [] %>
      <input type="text"/>
      </form>
      <%= f=form_for :form, "", [] %>
      <input type="text"/>
      </form>
      <%=  f = form_for :form, "", [] %>
      <input type="text"/>
      </form>
      <%= form_for :form, "", [] %>
      <input type="text"/>
      </form>
    END

    expected = code <<-END
      <%= f = form_for :form, "", [] %>
        <input type="text"/>
      </form>
      <%= f    =   form_for :form, "", [] %>
        <input type="text"/>
      </form>
      <%= f=form_for :form, "", [] %>
        <input type="text"/>
      </form>
      <%=  f = form_for :form, "", [] %>
        <input type="text"/>
      </form>
      <%= form_for :form, "", [] %>
      <input type="text"/>
      </form>
    END

    expect(described_class.format(source, {engine: "eex"})).to eq(expected)
  end

  it "indents special form_for for multiline tags" do
    source = code <<-END
      <%= f = form_for :form, "", [a: 1,
        some_very_long_setting_in_a_new_line: 2] %>
      <input type="text"/>
      </form>
    END

    expected = code <<-END
      <%= f = form_for :form, "", [a: 1,
        some_very_long_setting_in_a_new_line: 2] %>
        <input type="text"/>
      </form>
    END

    expect(described_class.format(source, {engine: "eex"})).to eq(expected)
  end
end
