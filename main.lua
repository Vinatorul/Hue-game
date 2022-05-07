function love.load()
    love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
    love.window.setTitle("Hue game")

    m_col = 20
    m_row = 15

    shuffled = false
    dtotal = 0

    top_left = {r=1, g=1, b=0}
    top_right = {r=1, g=0, b=0}
    bot_left = {r=0, g=0, b=1}
    bot_right = {r=0, g=1, b=0}

    taken = nil
    taken_i = 0
    taken_j = 0
    taken_x_diff = 0
    taken_y_diff = 0

    moves = 0

    data = {}
    for i = 0,m_row,1
    do
        data[i] = {}
        for j = 0,m_col,1
        do
            r = top_left.r + (top_right.r - top_left.r) * j / m_col * (m_row - i) / m_row + (bot_left.r - top_left.r) * i /m_row * (m_col - j) / m_col + (bot_right.r - top_left.r) * i /m_row * j /m_col
            g = top_left.g + (top_right.g - top_left.g) * j / m_col * (m_row - i) / m_row + (bot_left.g - top_left.g) * i /m_row * (m_col - j) / m_col + (bot_right.g - top_left.g) * i /m_row * j /m_col
            b = top_left.b + (top_right.b - top_left.b) * j / m_col * (m_row - i) / m_row + (bot_left.b - top_left.b) * i /m_row * (m_col - j) / m_col + (bot_right.b - top_left.b) * i /m_row * j /m_col
            
            data[i][j] = {r=r, g=g, b=b, init_i=i, init_j=j, fixed=(i == 0 or j == 0 or i == m_row or j == m_col)}
        end
    end
end

function shuffle()
    for i = 0,m_row,1
    do
        for j = 0,m_col,1
        do
            new_i = love.math.random(1, m_row - 1)
            new_j = love.math.random(1, m_col - 1)
            if (not data[i][j].fixed) and (not data[new_i][new_j].fixed) then
                data[i][j], data[new_i][new_j] = data[new_i][new_j], data[i][j]
            end
        end
    end 
    shuffled = true
end

function is_win()
    ctr = 0
    for i = 0,m_row,1
    do
        for j = 0,m_col,1
        do
            if (data[i][j].init_i == i and data[i][j].init_j == j) then
                ctr = ctr + 1
            else
                break
            end
        end
    end
    return ctr == (m_row + 1) * (m_col + 1)
end

function love.update(dt)
    dtotal = dtotal + dt
    if (not shuffled) and (dtotal > 5) then
        shuffle()
    end
    if shuffled and is_win() then
        print("You win!")
        print("Total moves: ", moves)
        print("Reshuffling...")
        dtotal = 0
        shuffled = false
        moves = 0
    end
end

function love.mousepressed(x, y, button, istouch)
    if shuffled and (button == 1) then
        width, height = love.graphics.getDimensions( )
        w = (width - 40 - 2 * m_col) / (m_col + 1) 
        h = (height - 40 - 2 * m_row) / (m_row + 1)

        j = math.floor((x - 20) / (w + 2))
        i = math.floor((y - 20) / (h + 2))
        if i >= 0 and i <= m_row and j >= 0 and j <= m_col then
            if data[i][j].fixed or taken == data[i][j] then
                taken = nil
            elseif taken == nil then
                taken = data[i][j]
                taken_i = i
                taken_j = j

                taken_x_diff = x - (20 + j * (w + 2))
                taken_y_diff = y - (20 + i * (h + 2))
            else
                data[taken_i][taken_j], data[i][j] = data[i][j], data[taken_i][taken_j]
                taken = nil
                moves = moves + 1
            end
        end
    end
end

function love.draw()
    width, height = love.graphics.getDimensions( )
    w = (width - 40 - 2 * m_col) / (m_col + 1) 
    h = (height - 40 - 2 * m_row) / (m_row + 1)

    for i = 0,m_row,1
    do
        for j = 0,m_col,1
        do
            if not (data[i][j] == taken) then
                love.graphics.setColor(data[i][j].r, data[i][j].g, data[i][j].b)
                
                x = 20 + j * (w + 2)
                y = 20 + i * (h + 2)
                love.graphics.rectangle("fill", x, y, w, h)          
            end
        end
    end
    if not (taken == nil) then
        x, y = love.mouse.getPosition( )

        love.graphics.setColor(taken.r, taken.g, taken.b)
        love.graphics.rectangle("fill", x - taken_x_diff, y - taken_y_diff, w, h)
    end
end
