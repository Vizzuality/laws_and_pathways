import React from "react"
import PropTypes from "prop-types"
import { VictoryScatter, VictoryTooltip, VictoryGroup } from "victory";

const createRow = (dataRow, bubbleColor) => {
  return (
    <>
      <div>
        title
      </div>
      {dataRow.map(el => ( // = dataRow
        <div className="bubble-chart--cell" key={el}>
          <VictoryGroup style={{ height: 'auto' }}>
            <VictoryScatter
              style={{
                data: { fill: bubbleColor }, labels: { fill: bubbleColor }
              }}
              bubbleProperty="amount"
              maxBubbleSize={50}
              minBubbleSize={15}
              labels={({ datum }) => `Y: ${datum.y}`}
              labelComponent={<VictoryTooltip flyoutWidth={200} flyoutHeight={100} style={{ fontSize: '52px' }} />}
              data={[
                {x: 1, y: -4, amount: 30 },
                {x: 2, y: 4, amount: 40},
                {x: 3, y: 2,  amount: 25},
                {x: 4, y: 1, amount: 45}
              ]}
            />
          </VictoryGroup>
        </div>
      ))}
    </>
  )
}

const BubbleChart = () => {
  return (
    <div className="bubble-chart--container">
      <div></div>
      {[1, 2, 3, 4, 5].map(el => (
        <div key={el}>
          header
        </div>
      ))}
      {[1, 2, 3, 4, 5, 6, 7, 8].map(el => createRow([1, 2, 3, 4, 5], '#2465F5'))}
    </div>  
  );
}

BubbleChart.propTypes = {
  greeting: PropTypes.string
};
export default BubbleChart;
